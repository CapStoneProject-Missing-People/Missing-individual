import mongoose from "mongoose";

const { Schema, model } = mongoose;

const userSchema = Schema(
  {
    email: {
        type: String,
        required: [true, 'email is required']
    }, 
    password: {
        type: String,
        required: [true, 'Please add a user password']
    }
}, {
    timestamps: true // Remove unnecessary comma here
});


export default model("User", userSchema);