import feedBackModel from '../models/feedBackModel.js';
import Feedback from '../models/feedBackModel.js'
//@desc create feedback
//@route POST /api
//@access private
export const createFeedback = async (req, res) => {
  const { feedback, rating } = req.body;
  console.log(req.user)
  const user_id = req.user.userId
  try {
   const savedFeedback = await Feedback.create({
      user_id,
      feedback,
      rating
    });

    res.status(201).json({
      message: 'Feedback created successfully',
      feedback: savedFeedback,
    });
  } catch (error) {
    console.log(error)
    res.status(500).json({
      message: 'Server error',
      error: error.message,
    });
  }
};

//@desc get feedback
//@route POST /api
//@access private
export const getFeedBack = async (req, res) => {
  try {
    const feedbacks = await Feedback.find().lean().populate({path: 'user_id', select: ['name', 'createdAt']});
    res.status(200).json(feedbacks);
  } catch (error) {
    console.log(error)
    res.status(500).json({
      message: 'Server error',
      error: error.message,
    });
  }
};

export const deleteFeedback = async (req, res) => {
  try {
    const feedback = await feedBackModel.findById(req.params.feedBackId)
    if (!feedback) {
      return res.status(404).json({ message: "feedback not found" });
    }
    await feedback.deleteOne()
    res.status(200).json({ message: "feedback removed successfully"})
  } catch (error) {

  }
}