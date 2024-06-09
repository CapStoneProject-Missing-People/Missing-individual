import MissingPerson from "../models/missingPersonSchema.js";
import axios from "axios";
import { createFeature } from "./featureController.js";
import { sendNotificationToAllUsersAndGuests } from "./push-notification.controller.js";
import MergedFeaturesModel from "../models/mergedFeaturesSchema.js";

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
      baseReq = {
        ...base,
        clothingUpperClothType,
        clothingUpperClothColor,
        clothingLowerClothType,
        clothingLowerClothColor,
        body_size,
      };
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
    console.log('Parsed Data: ', parsedData); // Debugging line

    let userID = req.user.userId;

    // Handling feature creation
    const result = await createFeature(parsedData, timeSinceDisappearance, userID, res);
    if (typeof(result.message) === "string") {
      return res.status(400).json({status: result.statusCode, message: result.message});
    }
    console.log('result')
    console.log(result);

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
    console.log(newMissingPerson._id);
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
    return res.status(500).json({ message: 'Feature cannot be created, Please try again!' });
  }
};

export const GetMissingPerson = async (req, res) => {
  try {
    const userId = req.user.userId;
    const missingPeople = await MissingPerson.find({ userID: userId });

    const caseIds = missingPeople.map(person => person._id.toString());

    const matchesResponse = await axios.post('http://localhost:6000/get-face-matches', {
      personIds: caseIds,
    });

    if (matchesResponse.status !== 200) {
      throw new Error('Failed to get face matches from external API');
    }

    const matchesData = matchesResponse.data.facematch;
    const matchedPeopleResults = missingPeople.map(person => ({
      ...person.toObject(),
      imageBuffers: person.imageBuffers.map(buffer => {
        return Buffer.isBuffer(buffer) ? buffer.toString('base64') : buffer;
      }),  // Convert buffers to Base64 strings if necessary
      matches: (matchesData[person._id.toString()] || []).map(match => ({
        ...match,
        imageBuffer: match.imageBuffer.map(buffer => {
          return Buffer.isBuffer(buffer) ? buffer.toString('base64') : buffer;
        })  // Convert buffers to Base64 strings if necessary
      }))
    }));

    res.status(200).json({ success: true, data: matchedPeopleResults });
  } catch (error) {
    console.error('Error getting missing person:', error.message);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};


export const GetMergedId = async (req, res) => {
  console.log('inside')
  try {
    const { caseId } = req.params;
    console.log(caseId);
    
    // Search for the MergedFeature using the caseId
    const mergedFeature = await MergedFeaturesModel.findOne({ missing_case_id: caseId });
    
    if (!mergedFeature) {
      return res.status(404).json({ message: "MergedFeature not found" });
    }
    
    // Get the id of the mergedFeature
    const mergedFeatureId = mergedFeature._id;
    
    // get missing person
    const response =  await MergedFeaturesModel.findById(mergedFeatureId).lean().populate({
      path: 'missing_case_id',
      select: ['status', 'imageBuffers', 'dateReported']
    });
    console.log(response)
    // Use the response in the API response
    return res.status(200).json({ response });
  } catch (error) {
    console.error('Error getting merged feature:', error.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

export const UpdateMissingStatusToFound = async (req, res) => {
  try {
    const { caseId } = req.params;

    // Find the missing person record by caseId
    const missingPerson = await MissingPerson.findById(caseId);

    if (!missingPerson) {
      return res.status(404).json({ message: "Missing person not found" });
    }

    // Update the missing status to "found"
    missingPerson.status = "found";
    await missingPerson.save();

    return res.status(200).json({ message: "Missing status updated to found" });
  } catch (error) {
    console.error('Error updating missing status:', error.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

export const UpdateMissingStatusToMissing = async (req, res) => {
  try {
    const { caseId } = req.params;

    // Find the missing person record by caseId
    const missingPerson = await MissingPerson.findById(caseId);

    if (!missingPerson) {
      return res.status(404).json({ message: "Missing person not found" });
    }

    // Update the missing status to "missing"
    missingPerson.status = "missing";
    await missingPerson.save();

    return res.status(200).json({ message: "Missing status updated to missing" });
  } catch (error) {
    console.error('Error updating missing status to missing:', error.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

export const UpdateMissingStatusToPending = async (req, res) => {
  try {
    const { caseId } = req.params;
    console.log(caseId)

    // Find the missing person record by caseId
    const missingPerson = await MissingPerson.findById(caseId);

    if (!missingPerson) {
      return res.status(404).json({ message: "Missing person not found" });
    }

    // Update the missing status to "pending"
    missingPerson.status = "pending";
    await missingPerson.save();

    return res.status(200).json({ message: "Missing status updated to pending" });
  } catch (error) {
    console.error('Error updating missing status to pending:', error.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};