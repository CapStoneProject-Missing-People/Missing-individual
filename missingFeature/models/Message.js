import mongoose from 'mongoose';

const { Schema, model } = mongoose;

const MessageSchema = new Schema({
  sender: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  receiver: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  message: { type: String },
  imageBase64: { type: String }, // Changed from imageUrl to Base64
  time: { type: Date, default: Date.now },
  read: { type: Boolean, default: false },
  status: { type: String, enum: ['sent', 'delivered', 'read'], default: 'sent' }
}, {
  toJSON: {
    virtuals: true,
    transform: function(doc, ret) {
      // Add virtual property for image URL if needed
      if (ret.imageBase64) {
        ret.imageUrl = `/api/messages/${ret._id}/image`;
      }
      delete ret.imageBase64; // Optional: hide Base64 in responses
      return ret;
    }
  }
});

// Virtual for image URL (optional)
MessageSchema.virtual('imageUrl').get(function() {
  return this.imageBase64 ? `/api/messages/${this._id}/image` : null;
});

// Add validation to prevent self-messages
MessageSchema.pre('save', function(next) {
  if (this.sender.equals(this.receiver)) {
    const err = new Error('Cannot send message to yourself');
    return next(err);
  }
  next();
});

// Indexes
MessageSchema.index({ sender: 1, receiver: 1, time: -1 });

const Message = model('Message', MessageSchema);

export default Message;