import User from "../models/userModel.js";
import MissingPerson from "../models/missingPersonSchema.js";

//@desc Get all user
//@route GET /api/admin/getAll
//@access admin only
export const getAllUsers = async (req, res) => {
  try {
    const users = await User.find({ role: "user" }).select("-__v -password");
    res.json(users);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};
export const getAllAdmins = async (req, res) => {
  try {
    const users = await User.find({ role: "admin" }).select("-__v -password");
    res.json(users);
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
    //remove posts made by the user
    await MissingPerson.deleteMany({ userID });
    //remove user
    await User.findOneAndDelete({ _id: userID });
    res.json({ msg: "user deleted" });
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
