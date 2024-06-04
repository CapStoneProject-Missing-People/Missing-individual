import FaceMatchResult from "../schema/faceMatch.js";

export const FaceMatch = async (req, res) => {
  console.log('entered to fetch missing match')
  try {
    const { personIds } = req.body;
    const matches = await FaceMatchResult.find({ person_id: { $in: personIds } });
  
    if (!matches.length) {
      return res.status(200).json({
        success: true,
        message: 'No face match results found.',
        facematch: [],
      });
    };
    
  
    const groupedMatches = matches.reduce((acc, match) => {
      if (!acc[match.person_id]) {
        acc[match.person_id] = [];
      }
      // Include desired properties in the response object
      acc[match.person_id].push({
        distance: match.distance,
        similarity: match.similarity,
        createdAt: match.createdAt,
        isMatch: match.isMatch,
        imageBuffer: match.imageBuffers
      });
      return acc;
    }, {});
  console.log(groupedMatches);
    res.status(200).json({success: true,facematch: groupedMatches});
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
