const fs = require('fs');

export const FetchImageBuffer = async (imagePaths) => {
  try {
    if (!Array.isArray(imagePaths) || imagePaths.length === 0) {
      return null;
    }

    // Read image files from the file system based on the image paths
    const images = [];
    for (const imagePath of imagePaths) {
      if (fs.existsSync(imagePath)) {
        const imageData = fs.readFileSync(imagePath);
        const base64Image = Buffer.from(imageData).toString("base64");
        images.push(base64Image);
      } else {
        console.error(`File not found: ${imagePath}`);
        images.push(null);
      }
    }

    return images;
  } catch (err) {
    console.error(`Error reading image files: ${err}`);
    return null;
  }
};
