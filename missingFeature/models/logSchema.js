import mongoose from 'mongoose';

const { Schema, model } = mongoose;

const actionLogSchema = new Schema({
  timestamp: { type: Date, default: Date.now },
  action: { type: String, required: true },
  user_id: { type: String, required: true },
  user_agent: {type: String, required: true},
  method: { type: String, required: true },
  ip: { type: String, required: true },
  status: { type: Number, required: true },
  error: { type: String, default: null },
  logLevel: { type: String, default: "info" },
});

const ActionLog = model("ActionLog", actionLogSchema);

export default ActionLog;
