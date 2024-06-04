import { User } from "../models/userModel.js";
import MergedFeaturesModel from "../models/mergedFeaturesSchema.js";
import MissingPerson from "../models/missingPersonSchema.js";


export const getOverallStatistics = async (req, res) => {
  try {
    const userCount = await User.countDocuments({role: 2001});
    const postCount = await MergedFeaturesModel.countDocuments();
    const missingCount = await MissingPerson.countDocuments({status: "missing"});
    const foundCount = await MissingPerson.countDocuments({status: "found"});
    const pendingCount = await MissingPerson.countDocuments({status: "pending"});


    const maleCount = await MergedFeaturesModel.countDocuments({
      gender: "male",
    });
    const femaleCount = await MergedFeaturesModel.countDocuments({
      gender: "female",
    });

    const ageRanges = {
      "0-17": 0,
      "18-25": 0,
      "26-35": 0,
      "36-45": 0,
      "46-60": 0,
      "61+": 0,
    };

    const persons = await MergedFeaturesModel.find();
    persons.forEach((person) => {
      const age = person.age;
      if (age <= 17) ageRanges["0-17"] += 1;
      else if (age <= 25) ageRanges["18-25"] += 1;
      else if (age <= 35) ageRanges["26-35"] += 1;
      else if (age <= 45) ageRanges["36-45"] += 1;
      else if (age <= 60) ageRanges["46-60"] += 1;
      else ageRanges["61+"] += 1;
    });
    console.log({ userCount, postCount, maleCount, femaleCount, ageRanges, missingCount, pendingCount, foundCount });
    res.status(200).json({
      userCount,
      postCount,
      maleCount,
      femaleCount,
      ageRanges,
      missingCount,
      pendingCount,
      foundCount
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: "Internal server error" });
  }
};
