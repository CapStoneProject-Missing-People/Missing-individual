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

    // Filter out matches with person_id "unknown"
    const filteredMatches = matches.filter(match => match.person_id !== "unknown");

    const groupedMatches = filteredMatches.reduce((acc, match) => {
      if (!acc[match.person_id]) {
        acc[match.person_id] = [];
      }
      acc[match.person_id].push({
        id: match._id,
        location: match.location,
        contact: match.contact,
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
export const updateMatchInfo = async (req, res) => {
  try {
    const { matchId, contact, location } = req.body;

    // Find the match by matchId
    const match = await FaceMatchResult.findById(matchId);

    if (!match) {
      return res.status(404).json({
        success: false,
        message: 'Match not found.',
      });
    }

    // Update the match with provided contact and location
    if (contact) {
      match.contact = contact;
    }
    if (location) {
      match.location = location;
    }

    // Save the updated match
    await match.save();

    res.status(200).json({
      success: true,
      message: 'Match updated successfully.',
    });
  } catch (error) {
    console.error('Error updating match:', error.message);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

export const updateMatchStatus = async (req, res) => {
  try {
    const { matchId, isMatch } = req.body;

    // Find the match by matchId
    const match = await FaceMatchResult.findById(matchId);

    if (!match) {
      return res.status(404).json({
        success: false,
        message: 'Match not found.',
      });
    }

    // Update the match with provided isMatch status
    match.isMatch = isMatch;

    // Save the updated match
    await match.save();

    res.status(200).json({
      success: true,
      message: 'Match status updated successfully.',
    });
  } catch (error) {
    console.error('Error updating match status:', error.message);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};