import ActionLog from "../models/logSchema.js";

// function to Create a new action log
export const AddActionLog = async (logData) => {
  try {
    await ActionLog.create(logData);
    console.log("Action logged successfully");
  } catch (error) {
    console.error("Error logging action:", error);
  }
};

// api gate way to add action log
export const AddActionLogGateWay = async (req, res) => {
  try {
    const logData = req.body; // Expecting log data in the request body
    await ActionLog.create(logData);
    console.log("Action logged successfully");
    res.status(200).json({ message: "Action logged successfully" });
  } catch (error) {
    console.error("Error logging action:", error);
    res.status(500).json({ error: "Error logging action" });
  }
};

// Get all action logs
export const getAllActionLogs = async (req, res) => {
  try {
    const logs = await ActionLog.find();
    res.status(200).json(logs);
  } catch (error) {
    console.error("Error getting action logs:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};


// Get a specific action log by ID
export const getActionLogByID = async (req, res) => {
  try {
    console.log(req.params.logId)
    const log = await ActionLog.findById(req.params.logId);
    if (!log) {
      return res.status(404).json({ error: "Action log not found" });
    }
    res.status(200).json(log);
  } catch (error) {
    console.error("Error getting action log:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// Get specific action logs for a user
export const getActionLogByUser = async (req, res) => {
  try {
    const logs = await ActionLog.find({ user_id: req.params.userId });
    if (!logs || logs.length === 0) {
      return res
        .status(404)
        .json({ error: "Action logs not found for the specified user" });
    }
    res.status(200).json(logs);
  } catch (error) {
    console.error("Error getting action logs for user:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};
