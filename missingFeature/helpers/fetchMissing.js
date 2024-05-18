import MissingPerson from "../models/missingPersonSchema";

export const FetchMissingPerson = async (missingId) => {
  try {
    // Retrieve the missing person record from the database
    const missingPerson = await MissingPerson.findById(missingId);

    if (!missingPerson) {
      return null;
    }
    const { imagePaths, userID, dateReported, status, faceFeatureCreated } = missingPerson;

    // Read image files from the file system based on the image paths
    const images = [];
    for (const imagePath of imagePaths) {
      const imageData = fs.readFileSync(imagePath);
      const base64Image = Buffer.from(imageData).toString("base64");
      images.push(base64Image);
    }

    return {images, userID, dateReported, status, faceFeatureCreated};
  } catch (err) {
    return null;
  }
};

