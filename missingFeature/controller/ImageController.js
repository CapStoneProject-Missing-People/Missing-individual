import mergedFeatureSchema from "../models/mergedFeatureSchema.js";
import MissingPerson from "../models/missingPersonSchema.js";

export const fetchAllMissingPeopleWithNames = async (req, res) => {
  try {
    // Fetch all MergedFeatures documents and populate the missing_case_id field
    const mergedFeaturesList = await mergedFeatureSchema
      .find()
      .populate("missing_case_id");

    if (!mergedFeaturesList.length) {
      return res.status(404).json({ message: "No merged features found." });
    }

    const results = mergedFeaturesList.map((mergedFeatures) => {
      const missingPerson = mergedFeatures.missing_case_id;

      if (missingPerson) {
        // Extract imageBuffers from the MissingPerson document
        const imageBuffers = missingPerson.imageBuffers;
        // Extract name from the MergedFeatures document
        const name = mergedFeatures.name;
        // Format the name
        const fullName = `${name.firstName} ${name.middleName || ""} ${
          name.lastName
        }`.trim();

        return {
          imageBuffers,
          name: fullName,
        };
      } else {
        return {
          message: `No missing person found for merged features ID: ${mergedFeatures._id}`,
        };
      }
    });

    res.status(200).json(results);
  } catch (error) {
    console.error("Error fetching missing people with names:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

export const updateImageBuffers = async (req, res) => {
  try {
    const { missingId } = req.body;
    const images = req.files;

    const imageBuffers = images.map((image) => image.buffer);

    // Find the MissingPerson document by ID and update the imageBuffers field
    const missingPerson = await MissingPerson.findByIdAndUpdate(
      missingId,
      { imageBuffers },
      { new: true }
    );

    if (!missingPerson) {
      return res.status(404).json({ message: "Missing person not found." });
    } else {
      const response = await axios.post(
        "http://localhost:6000/add-face-feature",
        {
          images: imageBuffers,
          person_id: missingId,
        }
      );
    }

    res
      .status(200)
      .json({ message: "Image buffers updated successfully", missingPerson });
  } catch (error) {
    console.error("Error updating image buffers:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};
