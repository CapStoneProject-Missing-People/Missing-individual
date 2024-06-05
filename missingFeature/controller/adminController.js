import {User} from "../models/userModel.js";
import MissingPerson from "../models/missingPersonSchema.js";
import MergedFeaturesModel from "../models/mergedFeaturesSchema.js";
import initializeFeaturesModel from "../models/featureModel.js"
import feedBackModel from "../models/feedBackModel.js";
import ActionLog from "../models/logSchema.js";



//@desc Get all user
//@route GET /api/admin/getAll
//@access admin with read privilege and superAdmin only
export const getAllUsers = async (req, res) => {
  try {
    const users = await User.find({ role: 2001 }).select("-__v -password");
    res.json(users);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

//@desc Get all user posts
//@route GET /api/admin/getAllPost
//@access admin with read privilege and superAdmin only
export const getAllPosts = async (req, res) => {
  try {
    let filterCriteria = {};

    // Map age ranges to MongoDB query conditions
    const ageRanges = {
      "1-4": { $gte: 1, $lte: 4 },
      "5-10": { $gte: 5, $lte: 10 },
      "11-15": { $gte: 11, $lte: 15 },
      "16-20": { $gte: 16, $lte: 20 },
      "21-30": { $gte: 21, $lte: 30 },
      "31-40": { $gte: 31, $lte: 40 },
      "41-50": { $gte: 41, $lte: 50 },
      ">51": { $gt: 51 },
    };

    //check if age range filter is provided in the request
    if (req.query.ageRange) {
      const ageRangeQuery = ageRanges[req.query.ageRange];
      if (ageRangeQuery) {
        filterCriteria.age = ageRangeQuery;
      } else {
        throw new Error("invalid filter criteria age range");
      }
    }

    if (req.query.filterBy && req.query[req.query.filterBy]) {
      const nameField = `name.${req.query.filterBy}`;
      filterCriteria[nameField] = {
        $regex: req.query[req.query.filterBy],
        $options: "i",
      };
    }

    // If user is authenticated, filter features by user ID
    if (req.user) {
      // Check if the user wants to view their own features
      if (req.query.ownFeatures === "true") {
        filterCriteria.user_id = req.user.userId;
      }
    }
    const features = await MergedFeaturesModel.find(filterCriteria)
      .lean()
      .populate({
        path: "missing_case_id",
        select: ["status", "imageBuffers", "dateReported"],
      });
    console.log("features: ", features);

    res.status(200).json(features);
  } catch (error) {
    res.status(500).json({ error: "Server error" });
    console.log("Error ferching features: ", error);
  }
};

//@desc Get all admins
//@route GET /api/admin/getAllAdmins
//@access superAdmin only
export const getAllAdmins = async (req, res) => {
  try {
    const users = await User.find({ role: 3244 }).select("-__v -password");
    res.json(users);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

//@desc Get all the data of logged in users from ActionLog database
//@route GET /api/admin/getlogInData
//@access admins only
export const getLoggedInUserData = async (req, res) => {
  try {
    const data = await ActionLog.find({action: "Login", logLevel: "info"});
    res.json(data);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

//@desc update the users profile
//@route GET /api/admin/updateUserProfile
//@access admin with privilege and superAdmin
export const updateUserProfile = async (req, res) => {
  const userID = req.params.userId;
  const { email, name, phoneNo } = req.body;

  try {
    // Find the user by ID
    const user = await User.findById(userID);
    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    // Check if at least one field is provided for update
    if (!email && !name && !phoneNo) {
      return res.status(400).json({ msg: "No fields provided for update" });
    }

    // Update user fields
    if (email) user.email = email;
    if (name) user.name = name;
    if (phoneNo) user.phoneNo = phoneNo;

    // Save updated user
    await user.save();

    res.json({ msg: "User profile updated successfully" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

//@desc delete any user
//@route DELETE /api/admin/delete/:userId
//@access admin

export const deleteUserProfile = async (req, res) => {
  const userID = req.params.userId;
  
  try {
    // Find the user by ID
    const user = await User.findById(userID);
    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }
    
    // Check if the user's role is "user" or "admin"
    if (user.role !== 2001) {
      return res
      .status(403)
      .json({ msg: "Cannot delete user with role: " + user.role });
    }
    
    const feedbackToDelete = await feedBackModel.findOne({ user_id: userID})
    if (feedbackToDelete){
      const feedbackId = feedbackToDelete._id
      await feedBackModel.deleteOne(feedbackId)
    }
    const mergedFeatureToDelete = await MergedFeaturesModel.findOne({ user_id: userID })
    console.log(mergedFeatureToDelete)
    const timeSinceDisappearance = await mergedFeatureToDelete.timeSinceDisappearance
    console.log(timeSinceDisappearance)
    const Features = await initializeFeaturesModel(timeSinceDisappearance)
    console.log(Features)
    // Remove posts made by the user (if any)
    await MissingPerson.deleteMany({ userID });
    // remove post from merged features model(if any)


    await MergedFeaturesModel.deleteMany({ user_id: userID });
    await Features.deleteMany({ user_id: userID });
    // Remove the user
    await User.findOneAndDelete({ _id: userID });

    res.json({ msg: "User deleted" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

//@desc delete admin profile
//@route DELETE /api/admin/deleteAdmin/:userId
//@access superAdmin
export const deleteAdmin = async (req, res) => {
  const userID = req.params.userId;

  try {
    // Find the user by ID
    const user = await User.findById(userID);
    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    // Check if the user's role is "user" or "admin"
    if (user.role !== 3244) {
      return res.status(403).json({ msg: "Only admins can be deleted" });
    }

    // Remove posts made by the user (if any)
    await MissingPerson.deleteMany({ userID });

    // remove post from merged features model (if any)
    await MergedFeaturesModel.deleteMany({ user_id: userID });

    // Remove the user
    await User.findOneAndDelete({ _id: userID });

    res.json({ msg: "Admin deleted" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

//@desc delete user post
//@route DELETE /api/admin/delete/:userId
//@access admin
export const deleteUserPost = async (req, res) => {
  const postID = req.params.postId;

  try {
    const post = await MergedFeaturesModel.findById({_id: postID});
    if (!post) {
      return res.status(404).json({ msg: "Post not found" });
    }
    const missingPeopleId = post.missing_case_id;

    // remove post from merged features model
    await MergedFeaturesModel.deleteOne({ _id: postID });

    // remove post from merged features model
    await MissingPerson.deleteOne({ _id: missingPeopleId });

    res.json({ msg: "user post deleted" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

export const updateUserRole = async (req, res) => {
  const userID = req.params.userId;
  const { role } = req.body;

  try {
    // Check if the user exists
    const user = await User.findById(userID);
    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    // Update the role of the user
    user.role = role;
    await user.save();

    res.json({ msg: "User role updated successfully" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

//@desc give admins certain privileges
//@route PATCH /api/admin/updatePermissions/:userId
//@access superAdmin
export const updatePermissions = async (req, res) => {
  const userID = req.params.userId;
  const { permissions } = req.body;

  try {
    const user = await User.findById(userID);
    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    if (user.role !== 3244) {
      return res
        .status(400)
        .json({ msg: "Only admins can have permissions updated" });
    }

    user.permissions = permissions;
    await user.save();

    res.json({ msg: "Permissions updated successfully" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};
