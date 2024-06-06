import FaceMatchResult from "../schema/faceMatch.js";

export const FaceMatch = async (req, res) => {
  try {
    const { personIds } = req.body;
    const matches = await FaceMatchResult.find({ person_id: { $in: personIds } });

    if (!matches.length) {
      return res.status(200).json({
        success: true,
        message: 'No face match results found.',
        facematch: [],
      });
    }

    const groupedMatches = matches.reduce((acc, match) => {
      if (!acc[match.person_id]) {
        acc[match.person_id] = [];
      }
      acc[match.person_id].push({
        distance: match.distance,
        similarity: match.similarity,
        createdAt: match.createdAt,
        isMatch: match.isMatch,
        imageBuffer: (match.imageBuffers || []).map(buffer => {
          return Buffer.isBuffer(buffer) ? buffer.toString('base64') : buffer;
        })  // Convert buffers to Base64 strings if necessary
      });
      return acc;
    }, {});

    res.status(200).json({ success: true, facematch: groupedMatches });
  } catch (error) {
    console.error('Error fetching face match results:', error.message);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};
