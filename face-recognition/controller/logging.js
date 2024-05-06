import ActionLog from "../schema/logSchema.js";

// Create a new action log
export const addActionLog = async (req, res) => {
  try {
    const { timestamp, action, user_id, details } = req.body;
    const { method, ip, userAgent, status, duration, error, sessionId } =
      details; // Extract log details

    const newLog = await ActionLog.create({
      timestamp,
      action,
      user_id,
      method,
      ip,
      userAgent,
      status,
      duration,
      error,
      sessionId,
    });

    res.status(201).json(newLog);
  } catch (error) {
    console.error("Error creating action log:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};


// Get all action logs
export const getAllActionLogs = async (req, res) => {
  try {
    const logs = await ActionLogs.find();
    res.status(200).json(logs);
  } catch (error) {
    console.error("Error getting action logs:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};


// Get a specific action log by ID
export const getActionLogByID = async (req, res) => {
  try {
    const log = await ActionLogs.findById(req.params.logId);
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
    const logs = await ActionLogs.find({ user_id: req.params.userId });
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
