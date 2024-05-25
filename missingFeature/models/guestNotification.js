import mongoose from "mongoose";

const { Schema, model } = mongoose;

const guestFcmTokenSchema = new Schema(
  {
    fcmToken: {
      type: String,
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

const GuestFcmToken = model("guestFcmToken", guestFcmTokenSchema);

export default GuestFcmToken;
