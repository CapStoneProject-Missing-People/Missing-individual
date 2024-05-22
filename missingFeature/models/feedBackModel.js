import mongoose from "mongoose";

const { Schema, model } = mongoose;

const feedbackSchema = new Schema({
    user_id: {
        type: Schema.Types.ObjectId ,
        required: true,
        ref: "user",
    },
    feedbackResponse: {
        type: String,
        enum: ["Thank you", "we will review it", "Thank you for your feedback"],
        default: "Thank you for your feedback",
    },
    feedback: {
        type: String,
        required: true,
    },
    rating: {
        type: Number,
        min: 1,
        max: 5,
        required: true,
    },
}, {
    timestamps: true,
});

export default model('Feedback', feedbackSchema);
