import MissingPerson from "../models/missingPersonSchema.js";
import User from "../models/userModel.js";

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
    //const profile = await User.findOne({ _id: userID });
    const profile = await User.findOne({ _id: userID }).select(
      "-_id -password -createdAt -updatedAt -__v"
    );
    if (!profile) {
      return res.status(400).json({ msg: "No profile found" });
    } else {
      const posts = await MissingPerson.find({ userID }).select(
        "-_id -__v -userID -faceFeatureCreated -imageBuffers"
      );
      if (!posts) {
        res.json({ msg: "There are no posts", profile });
      }
      //const combinedData = { profile, posts };
      res.json(profile);
    }
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};

//@desc update current user
//@route PUT /api/profile/update
//@access private
export const updateUserProfile = async (req, res) => {
  const { name, email, phoneNo } = req.body;
  const profileFields = {};
  if (name) profileFields.name = name;
  if (email) profileFields.email = email;
  if (phoneNo) profileFields.phoneNo = phoneNo;

  try {
    const userID = req.user.userId;
    let profile = await User.findOne({ _id: userID });
    if (profile) {
      profile = await User.findOneAndUpdate(
        { _id: userID },
        { $set: profileFields },
        { new: true }
      ).select("-_id -password -createdAt -updatedAt -__v");
      return res.json(profile);
    }
    return res.status(400).json({ msg: "No profile found" });
  } catch (err) {
    console.error(err);
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
    await MissingPerson.deleteMany({ userID });
    //remove user
    await User.findOneAndDelete({ _id: userID });
    res.json({ msg: "user deleted" });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
};
