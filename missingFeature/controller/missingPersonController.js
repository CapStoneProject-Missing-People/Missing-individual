import MissingPerson from "../models/missingPersonSchema.js";
import axios from "axios";
import fs from "fs";
import path, { parse } from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";
import { createFeature } from "./featureController.js";
import { error } from "console";
import { features } from "process";

export const CreateMissingPerson = async (req, res) => {
  try {
    console.log(req.body)
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
      console.log(baseReq)
    }

    const parsedData = {};
    const clothing = {};
    
    for (let key in req.body) {
      let value = req.body[key].trim().replace(/^"(.*)"$/, '$1'); 

      if (key === "age") {
        parsedData[key] = parseInt(value); 
      } else if (key === "firstName" || key === "middleName" || key === "lastName") {
        if (!parsedData.name) {
          parsedData.name = {};
        }
        parsedData.name[key] = value;
      } else if (key.startsWith("clothing")) {
        let [clothingType, clothingProperty] = key.split("Cloth");
        clothingType = clothingType === "clothingUpper" ? "upper" : "lower"; 
        clothingProperty = clothingProperty === "Type" ? "clothType" : "clothColor"; 
        if (!clothing[clothingType]) {
          clothing[clothingType] = {};
        }
        clothing[clothingType][clothingProperty] = value;
      } else if (key === "eyeDescription" || key === "noseDescription" || key === "hairDescription" || key === "lastSeenAddressDes") {
        if (!parsedData.description) {
          parsedData.description = "";
        }
        parsedData.description += value + "."; 
      } else {
        parsedData[key] = value;
      }
    }
    parsedData.clothing = clothing;    

    let userID = req.user.userId;
    let userIDString = userID.toString();

    // Handling feature creation
    const result = await createFeature(parsedData, timeSinceDisappearance, userID, res);
    if (typeof(result) === "string") {
     return res.status(400).json({message: result})
    }

    console.log(result)

    const images = req.files;
    const imageBuffers = images.map((image) => image.buffer);
    const imagePaths = [];

    const moduleDir = dirname(fileURLToPath(import.meta.url));
    const uploadsDir = path.join(moduleDir, "..", "uploads", userIDString);

    // Create the directory if it doesn't exist
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }

    // Save images to the uploads directory
    images.forEach((image) => {
      const filename = image.originalname;
      const filepath = path.join(uploadsDir, filename);
      fs.writeFileSync(filepath, image.buffer);
      imagePaths.push(filepath); // Saving the image path
    });

    // Create a new missing person record in the database
    const newMissingPerson = new MissingPerson({
      userID,
      imagePaths,
    });

    const person_id = newMissingPerson._id.toString();

    const response = await axios.post(
      "http://localhost:6000/add-face-feature",
      {
        images: imageBuffers,
        person_id: person_id,
      }
    );

    if (response.status === 200) {
      // change the faceFeatureCreated to true
      newMissingPerson.faceFeatureCreated = true;
    }
    await newMissingPerson.save();
    result.createdFeature.missing_case_id = newMissingPerson._id;
    console.log(result.createdFeature.missing_case_id)
    await result.createdFeature.save();
    return res
      .status(201)
      .json({ message: "Missing person record created successfully." , createdFeatures: result});
  } catch (error) {
    // Handle unexpected errors
    console.error('Error occurred:', error);
    return res.status(500).json({ error: error});
  }
};

