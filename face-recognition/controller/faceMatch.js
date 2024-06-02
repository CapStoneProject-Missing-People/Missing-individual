import FaceMatchResult from "../schema/faceMatch.js";

export const FaceMatch = async (req, res) => {
  try {
    console.log(req.body.personId)
    // Extract person_id from request (replace placeholder with your logic)
    const personId = req.body.personId || req.query.personId; // Check body or query params

    // Validate person_id presence and format
    if (!personId || typeof personId !== 'string' || personId.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Invalid or missing person ID.',
      });
    }

    // Fetch face match results from the database
    const faceMatchResults = await FaceMatchResult.find({ person_id: personId });

    if (!faceMatchResults.length) {
      return res.status(200).json({
        success: true,
        message: 'No face match results found.',
        facematch: [],
      });
    }

    // Respond with the face match results
    res.status(200).json({
      success: true,
      message: 'Face match results retrieved successfully.',
      facematch: faceMatchResults,
    });
  } catch (err) {
    console.error('Error fetching face match results:', err);
    res.status(500).json({
      success: false,
      message: 'An internal server error occurred while fetching face match results.',
    });
  }
};
