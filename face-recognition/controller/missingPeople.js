import MissingPerson, { find, findByIdAndUpdate, findByIdAndDelete } from "../models/missingPersonSchema";
import { post } from "axios";
import { createReadStream } from "fs";
import { join } from "path";
import FormData from "form-data";
import multer, { diskStorage } from "multer";

const selectiveStorage = diskStorage({
  destination: function (req, file, cb) {
    // Save to the root folder of the project
    cb(null, "./uploads");
  },
  filename: function (req, file, cb) {
    // Use the original file name
    cb(null, file.originalname);
  },
});

// Set up multer with custom storage
const upload = multer({
  storage: selectiveStorage,
});

// Endpoint for adding a missing person
router.post("/add-missing-person", upload.array("images"), async (req, res) => {
  try {
    const files = req.files;

    // Check if images are provided
    if (!files || files.length === 0) {
      return res
        .status(400)
        .json({ success: false, error: "Images are required" });
    }

    // Save the original name of the first file as image URL
    const imageUrl = files[0].originalname;

    // Create a new missing person instance
    const newMissingPerson = new MissingPerson({
      userID: req.body.userID,
      dateReported: req.body.dateReported || Date.now(),
      description: req.body.description,
      locationLastSeen: "Bole",
      status: req.body.status || "missing",
      age: "29",
      skinColor: "light",
      bodySize: "medium",
      height: "1.78",
      faceFeatureCreated: false, // Face feature not created initially
      // Assuming you want to store the filename instead of buffer
      imageURL: files[0].filename, // Set the image URL
    });

    // Save the new missing person to the database
    const savedMissingPerson = await newMissingPerson.save();

    // Prepare data to send to the add-face-feature endpoint
    const faceData = new FormData();
    faceData.append("person_id", savedMissingPerson._id);

    // Append each image file to the FormData object
    files.forEach(file => {
      faceData.append("images", createReadStream(join(__dirname, 'uploads', file.filename)));
    });

    // Send images and missing person ID to the add-face-feature endpoint
    const faceAdded = await post(
      "http://localhost:5000/add-face-feature",
      faceData,
      {
        headers: {
          ...faceData.getHeaders(), // Include headers from FormData
        },
      }
    );

    // Send response with success message
    res.status(200).json({
      success: true,
      message: `Missing person added \n${faceAdded.data.message}`,
      data: newMissingPerson,
    });
  } catch (error) {
    // Handle errors
    console.error("Error creating missing person:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Endpoint for retrieving missing individual cases
router.get("/api/get-missing-people", async (req, res) => {
  try {
    // Retrieve all missing person details from the database
    const missingPersons = await find();
    // Respond with the retrieved missing person details
    res.json({ success: true, data: missingPersons });
  } catch (error) {
    // Handle errors
    console.error("Error retrieving missing persons:", error);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

// Endpoint for updating a missing person
router.put("/update-missing-person/:id", async (req, res) => {
  try {
    const { id } = req.params;

    // Find the missing person by ID
    const missingPerson = await findByIdAndUpdate(id, req.body, {
      new: true,
    });

    // Check if missing person exists
    if (!missingPerson) {
      return res
        .status(404)
        .json({ success: false, error: "Missing person not found" });
    }

    res.status(200).json({
      success: true,
      message: "Missing person updated",
      data: missingPerson,
    });
  } catch (error) {
    console.error("Error updating missing person:", error);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

// Endpoint for deleting a missing person
router.delete("/delete-missing-person/:id", async (req, res) => {
  try {
    const { id } = req.params;

    // Find the missing person by ID and delete it
    const deletedMissingPerson = await findByIdAndDelete(id);

    // Check if missing person exists
    if (!deletedMissingPerson) {
      return res
        .status(404)
        .json({ success: false, error: "Missing person not found" });
    }

    res.status(200).json({
      success: true,
      message: "Missing person deleted",
      data: deletedMissingPerson,
    });
  } catch (error) {
    console.error("Error deleting missing person:", error);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});

export default router;
