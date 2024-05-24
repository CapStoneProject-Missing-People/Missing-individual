import MissingPerson from "../models/missingPersonSchema.js";
import axios from "axios";
import fs from "fs";
import path, { parse } from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";
import { createFeature } from "./featureController.js";
import { sendPushNotificationFunc } from "./push-notification.controller.js";

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
    console.log(req)
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
    // await sendPushNotificationFunc(
    //       {
    //         title: "New Missing Person",
    //         body:String(result['name']['firstName']),
    //         caseID: String(newMissingPerson._id),
    //         orderDate: new Date().toISOString(),
    //         fcmToken: "c9UznfvDSB-R2ocU30yARQ:APA91bEhK8JDntwHGFhVGgOI5Tcb_Hd16ilmVJ1s3Y6HVNlltCZNH_4KeKhrP5l0XQZ2PSY5j4ZY1sxf7AvRtoC2cLwpD4-T2s_rLZoQGb_WU_Wivh2Z0ID0-2fb9SErsHz63QeVzL2A"
    // }
    // )
    return res
      .status(201)
      .json({ message: "Missing person record created successfully.", createdFeatures: result });
  } catch (error) {
    // Handle unexpected errors
    console.error('Error occurred:', error);
    return res.status(500).json({ error: error.message });
  }
};
