import MissingPerson from "../models/missingPersonSchema.js";
import {User} from "../models/userModel.js";

//@desc Get current user
//@route GET /api/profile/current
//@access private
export const getUserProfile = async (req, res) => {
  try {
    console.log("in")
    if (!req.user) {
      return res.status(401).json({ msg: "Not authorized! Login First" });
    }
    const userID = req.user.userId;
    const profile = await User.findById({ userID }).select(
      "-_id -password -createdAt -updatedAt -__v"
    );
    if (!profile) {
      return res.status(400).json({ msg: "No profile found" });
    }
    res.json(profile);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

//@desc update current user
//@route PUT /api/profile/update
//@access private
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

//@desc delete current user
//@route DELETE /api/profile/delete
//@access private
export const deleteUserProfile = async (req, res) => {
  try {
    const userID = req.user.userId;
    //remove posts made by the user
    // await MissingPerson.deleteMany({ userID });
    //remove user
    await User.findOneAndDelete({ _id: userID });
    res.json({ msg: "user deleted" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};
