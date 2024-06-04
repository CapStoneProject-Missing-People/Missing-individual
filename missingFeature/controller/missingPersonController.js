import MissingPerson from "../models/missingPersonSchema.js";
import axios from "axios";
import { createFeature } from "./featureController.js";

export const CreateMissingPerson = async (req, res) => {
  try {
    console.log(req.body);
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
    if (typeof(result) === "string") {
      return res.status(404).json({ message: result });
    }
    console.log('result')
    console.log(result);

    const images = req.files;
    const imageBuffers = images.map((image) => image.buffer);
    console.log(imageBuffers);
    // Create a new missing person record in the database
    const newMissingPerson = new MissingPerson({
      userID,
      imageBuffers,
    });
    console.log("newMissId: ", newMissingPerson._id);
    console.log(imageBuffers);
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
    res.status(200).json({ message: "Missing person record created successfully.", createdFeatures: result });
  } catch (error) {
    // Handle unexpected errors
    console.error('Error occurred:', error);
    return res.status(500).json({ message: 'Feature cannot be created, Please try again!' });
  }
};
