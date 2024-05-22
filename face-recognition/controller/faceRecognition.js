import { uploadFaceFeature, checkFaceMatch } from "../face.js";
import FaceMatchResult from "../schema/faceMatch.js";
import { logData } from "../helper/helpers.js";

export const RecognizeFace = async (req, res) => {
  const startTime = Date.now(); // Start timer
  try {
    const file1 = req.files[0]?.buffer;
    if (!file1) {
      return res.status(400).json({ error: "Image is required." });
    }

    const result = await checkFaceMatch(file1);

    if (result.error) {
      return res.status(400).json({ error: result.error });
    }
    await FaceMatchResult.create({
      person_id: result.person_id,
      distance: result.distance,
      similarity: result.similarity,
    });
    
    await logData({
      action: "FaceRecognition",
      user_id: result.person_id || "",
      user_agent: req.headers["user-agent"],
      method: req.method,
      ip: req.socket.remoteAddress,
      status: 200,
      logLevel: "info"
    });
    res.json({
      person_id: result.person_id,
      distance: result.distance,
      confidence: result.similarity,
    });
  } catch (error) {
    console.error("Error checking face:", error);
    await logData({
      action: "FaceRecognition",
      user_id: result.person_id || "",
      user_agent: req.headers["User-Agent"],
      method: req.method,
      ip: req.ip,
      status: 500,
      error: error.message || 'Internal Server Error',
      logLevel: "error"
    });
    res.status(500).json({ error: "Internal server error" });
  } finally {
    const endTime = Date.now(); // End timer
    console.log("Total processing time:", endTime - startTime, "ms");
  }
};

export const addFaceFeature = async (req, res) => {
  const startTime = Date.now(); // Start timer

  try {
    console.log(req.body)
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

    console.log("image")
    // Check if any images are provided
    if (!images || images.length === 0) {
      return res.status(400).json({ message: "No images provided." });
    }
    console.log("after image")
    // Process each uploaded image for face recognition
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
