import {User} from "../models/userModel.js";
import MissingPerson from "../models/missingPersonSchema.js";
import MergedFeaturesModel from "../models/mergedFeaturesSchema.js";

//@desc Get all user
//@route GET /api/admin/getAll
//@access admin with privilege and superAdmin only
export const getAllUsers = async (req, res) => {
  try {
    const users = await User.find({ role: 2001 }).select("-__v -password");
    res.json(users);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
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

    // Remove posts made by the user (if any)
    await MissingPerson.deleteMany({ userID });
    // remove post from merged features model(if any)
    await MergedFeaturesModel.deleteMany({ user_id: userID });

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
    //remove posts made by the user
    await MissingPerson.deleteMany({ _id: postID });
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
