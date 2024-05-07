import MissingPerson from "../models/missingPersonSchema.js";
import axios from "axios";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";

export const CreateMissingPerson = async (req, res) => {
  try {
    const images = req.files;
    const imageBuffers = images.map((image) => image.buffer);
    const imagePaths = [];

    const { userID, locationLastSeen } = req.body;
    // Saving images to a dedicated folder
    const moduleDir = dirname(fileURLToPath(import.meta.url));
    const uploadsDir = path.join(moduleDir, "..", "uploads", userID);

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
      locationLastSeen,
      imagePaths,
    });

    const person_id = newMissingPerson._id.toString();

    const response = await axios.post(
      "http://localhost:5000/add-face-feature",
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
    res
      .status(201)
      .json({ message: "Missing person record created successfully." });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
