import { Canvas, Image } from "canvas";
import { loadImage } from 'canvas';
import faceapi from "face-api.js";
import FaceModel from "./schema/face-feature.js";
import { fileURLToPath } from 'url';
import { dirname } from 'path';


faceapi.env.monkeyPatch({ Canvas, Image });

async function LoadModels() {
  // Load the models
  // __dirname gives the root directory of the server
  const moduleDir = dirname(fileURLToPath(import.meta.url));
  await faceapi.nets.faceRecognitionNet.loadFromDisk(moduleDir + "/FaceModels");
  await faceapi.nets.faceLandmark68Net.loadFromDisk(moduleDir + "/FaceModels");
  await faceapi.nets.ssdMobilenetv1.loadFromDisk(moduleDir + "/FaceModels");
  await faceapi.nets.tinyFaceDetector.loadFromDisk(moduleDir + "/FaceModels");
}
LoadModels();

export const uploadFaceFeature = async (images, person_id) => {
  try {
    // const existingPerson = await MissingPerson.findById(person_id);
    // console.log(existingPerson);
    // if (!existingPerson) {
    //   throw new Error("Person not found in the MissingPerson database.");
    // }
    const descriptionsPromises = images.map(async (image) => {
      const imageBuffer = Buffer.from(image.data);
      const img = await loadImage(imageBuffer);
      const detection = await faceapi
        .detectSingleFace(img, new faceapi.TinyFaceDetectorOptions())
        .withFaceLandmarks()
        .withFaceDescriptor();
      return detection ? detection.descriptor : null;
    });

    // Use Promise.all to await all promises concurrently
    const descriptions = await Promise.all(descriptionsPromises);

    // Filter out null values (failed detections)
    const validDescriptions = descriptions.filter(
      (descriptor) => descriptor !== null
    );

    // Create a new face document with the given label and save it in DB
    const createFace = new FaceModel({
      person_id: person_id,
      feature_vector: validDescriptions,
    });

    await createFace.save();
    return true;
  } catch (error) {
    console.error("Error uploading labeled images:", error);
    return false;
  }
};

function getSimilarityPercentage(distance) {
  // Invert the distance to get similarity
  const similarity = 1 - distance;
  // Convert similarity to percentage
  const similarityPercentage = similarity * 100;
  return similarityPercentage;
}



export const checkFaceMatch = async (image) => {
  try {
    // Load the image asynchronously
    const img = await loadImage(image);

    // Faster face detection with TinyFaceDetector
    const detection = await faceapi
      .detectSingleFace(img, new faceapi.TinyFaceDetectorOptions())
      .withFaceLandmarks()
      .withFaceDescriptor();

    if (!detection) {
      throw new Error("Face not detected in the image.");
    }

    // Match the detected face with the database
    const result = await matchFaceDescriptor(detection.descriptor);

    // Calculate similarity percentage
    const similarityPercentage = getSimilarityPercentage(result[0]._distance);

    // Return only relevant information from the result
    return {
      person_id: result[0]._label,
      distance: result[0]._distance,
      similarity: similarityPercentage,
      faceFeautre: detection.descriptor
    };
  } catch (error) {
    console.error("Error detecting face:", error);
    return { error: error.message };
  }
};

const matchFaceDescriptor = async (descriptor) => {
  try {
    // Fetch face descriptors from the database
    const faces = await FaceModel.find({}, { person_id: 1, feature_vector: 1 });

    // Process the data and create faceapi.LabeledFaceDescriptors
    const labeledFaceDescriptors = faces.map((face) => {
      const descriptions = face.feature_vector.map(
        (desc) => new Float32Array(Object.values(desc))
      );
      return new faceapi.LabeledFaceDescriptors(
        face.person_id.toString(),
        descriptions
      );
    });

    // Load face matcher with the processed face descriptors
    const faceMatcher = new faceapi.FaceMatcher(labeledFaceDescriptors, 0.6);

    // Find the best match for the detected face
    const result = faceMatcher.findBestMatch(descriptor);

    return [result];
  } catch (error) {
    console.error("Error matching face descriptor: " + error.message);
    throw error;
  }
};
