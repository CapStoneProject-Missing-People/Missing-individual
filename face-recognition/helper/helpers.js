import axios from "axios";

export const logData = async (logDetails) => {
  try {
    await axios.post("http://localhost:4000/api/add_log_data", logDetails);
  } catch (error) {
    console.error("Error logging data:", error);
  }
};
