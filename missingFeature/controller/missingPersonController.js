import MissingPerson from "../models/missingPersonSchema.js";
import axios from "axios";
import { createFeature } from "./featureController.js";
import { sendNotificationToAllUsersAndGuests } from "./push-notification.controller.js";

export const CreateMissingPerson = async (req, res) => {
  try {
    const { timeSinceDisappearance } = req.params;
    let baseReq;
    if (timeSinceDisappearance > 2) {
      const {
        lastSeenLocation,
        medicalInformation,
        circumstanceOfDisappearance,
        ...base
      } = req.body;
      baseReq = {
        ...base,
        lastSeenLocation,
        medicalInformation,
        circumstanceOfDisappearance,
      };
    } else {
      const {
        clothingUpperClothType,
        clothingUpperClothColor,
        clothingLowerClothType,
        clothingLowerClothColor,
        body_size,
        ...base
      } = req.body;
      baseReq = base;
    }

    const parsedData = {};
    const clothing = {};

    for (let key in req.body) {
      let value = req.body[key];
      
      // Check if value is a string before calling trim
      if (typeof value === 'string') {
        value = value.trim().replace(/^"(.*)"$/, '$1');
      }

      if (key === "age") {
        parsedData[key] = parseInt(value);
      } else if (
        key === "firstName" ||
        key === "middleName" ||
        key === "lastName"
      ) {
        if (!parsedData.name) {
          parsedData.name = {};
        }
        parsedData.name[key] = value;
      } else if (key.startsWith("clothing")) {
        let [clothingType, clothingProperty] = key.split("Cloth");
        clothingType = clothingType === "clothingUpper" ? "upper" : "lower";
        clothingProperty =
          clothingProperty === "Type" ? "clothType" : "clothColor";
        if (!clothing[clothingType]) {
          clothing[clothingType] = {};
        }
        clothing[clothingType][clothingProperty] = value;
      } else if (
        key === "eyeDescription" ||
        key === "noseDescription" ||
        key === "hairDescription" ||
        key === "lastSeenAddressDes"
      ) {
        if (!parsedData.description) {
          parsedData.description = "";
        }
        parsedData.description += value + ".";
      } else {
        parsedData[key] = value;
      }
    }
    parsedData.clothing = clothing;
    console.log(req.user.userId);

    let userID = req.user.userId;
    let userIDString = userID.toString();

    // Handling feature creation
    const result = await createFeature(parsedData, timeSinceDisappearance, userID, res);
    if (typeof(result) === "string") {
      return res.status(400).json({message: result});
    }

    const images = req.files;
    const imageBuffers = images.map((image) => image.buffer);
    // Create a new missing person record in the database
    const newMissingPerson = new MissingPerson({
      userID,
      imageBuffers,
    });
    const response = await axios.post(
      "http://localhost:6000/add-face-feature",
      {
        images: imageBuffers,
        person_id: newMissingPerson._id,
      }
    );

    if (response.status === 200) {
      // change the faceFeatureCreated to true
      newMissingPerson.faceFeatureCreated = true;
    }
    await newMissingPerson.save();
    result.createdFeature.missing_case_id = newMissingPerson._id;
    result.mergedFeature.missing_case_id = newMissingPerson._id;
    await result.createdFeature.save();
    await result.mergedFeature.save();

    // Send push notification to all users and guests
    await sendNotificationToAllUsersAndGuests(
      "New Missing Person",
      `A new person named ${parsedData.name.firstName} ${parsedData.name.lastName} has been Added To the missing List.\n Click to see the detail`,
      result.mergedFeature._id.toString()
    );

    return res
      .status(201)
      .json({ message: "Missing person record created successfully.", createdFeatures: result });
  } catch (error) {
    // Handle unexpected errors
    console.error('Error occurred:', error);
    return res.status(500).json({ error: error.message });
  }
};

export const GetMissingPerson = async (req, res) => {
  console.log('Getting missing person');
  try {
    const userId = req.user.userId;
    const missingPeople = await MissingPerson.find({ userID: userId });

    const missingPersonIds = missingPeople.map(person => person._id);
    // console.log(missingPersonIds);

    const matchesResponse = await axios.post('http://localhost:6000/get-face-matches', {
      personIds: missingPersonIds,
    });

    if (matchesResponse.status !== 200) {
      throw new Error('Failed to get face matches from external API');
    }

    const matchesData = matchesResponse.data;
    console.log(matchesData.matches)
    const matchedPeopleResults = missingPeople.map(person => ({
      ...person.toObject(),
      matches: matchesData.facematch[person._id] || [],
    }));
    res.json(matchedPeopleResults);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
