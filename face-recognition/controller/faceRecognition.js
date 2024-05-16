import { uploadFaceFeature, checkFaceMatch } from "../face.js";
import multer from 'multer';

const upload = multer();

export const RecognizeFace = async (req, res) => {
  const startTime = Date.now(); // Start timer
  try {
    const file1 = req.files[0]?.buffer;
    console.log(req.files[0].buffer)
    if (!file1) {
      return res.status(400).json({ error: "Image is required." });
    }

    const result = await checkFaceMatch(file1);

    if (result.error) {
      return res.status(400).json({ error: result.error });
    }

    res.json({
      person_id: result.person_id,
      distance: result.distance,
    });
  } catch (error) {
    console.error("Error checking face:", error);
    res.status(500).json({ error: "Internal server error" });
  } finally {
    const endTime = Date.now(); // End timer
    console.log("Total processing time:", endTime - startTime, "ms");
  }
};

export const addFaceFeature = async (req, res) => {
  const startTime = Date.now(); // Start timer

  try {
    const {images, person_id} = req.body;
    // Check if person_id is provided
    
    if (!person_id) {
      return res.status(400).json({ message: "person_id is required." });
    }

    // Convert person_id to ObjectId
    // try {
    //   person_id = mongoose.Types.ObjectId();
    // } catch (error) {
    //   return res.status(400).json({ message: "Invalid person_id format." });
    // }

    // Check if any images are provided
    if (!images || images.length === 0) {
      return res.status(400).json({ message: "No images provided." });
    }
    // Process each uploaded image for face recognition
    console.log(images);
    if (images.length === 0) {
      return res.status(400).json({ message: "No images provided." });
    }
    let result = await uploadFaceFeature(images, person_id);

    if (result) {
      return res.status(200).json({ message: "Face stored" });
    } else {
      return res.json({ message: "Something went wrong" });
    }
  } catch (error) {
    console.error("Error uploading images:", error);
    throw new Error(error)
  } finally {
    const endTime = Date.now(); // End timer
    console.log("Total processing time:", endTime - startTime, "ms");
  }
};
