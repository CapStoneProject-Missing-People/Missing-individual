import pkg from 'mongoose';
const { Schema, model, models } = pkg;

// Define ActionLog schema
const actionLogSchema = new Schema({
  timestamp: { type: Date, default: Date.now },
  action: { type: String, required: true },
  user_id: { type: Schema.Types.ObjectId, ref: "User", required: true },
  method: { type: String, required: true }, // HTTP Method
  ip: { type: String, required: true }, // IP Address
  userAgent: { type: String, required: true }, // User Agent
  status: { type: Number, required: true }, // Response Status
  duration: { type: Number, required: true }, // Duration
  error: { type: String }, // Error Message
  sessionId: { type: String }, // Session ID
});

const ActionLog = models.ActionLog || model("ActionLog", actionLogSchema);

export default ActionLog;