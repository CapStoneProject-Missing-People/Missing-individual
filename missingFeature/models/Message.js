import mongoose from 'mongoose';

const { Schema, model } = mongoose;

const MessageSchema = new Schema({
  sender: { type: String, required: true },
  receiver: { type: String, required: true },
  message: { type: String },
  imageUrl: { type: String },
  time: { type: Date, default: Date.now },
  read: { type: Boolean, default: false }, // Add the read status
});

const Message = model('Message', MessageSchema);

export default Message;
