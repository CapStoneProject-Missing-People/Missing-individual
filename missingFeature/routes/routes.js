// Import necessary modules
import express from 'express';
import multer from 'multer';
import { CreateMissingPerson } from "../controller/missingPersonController.js";
import { AddActionLogGateWay, getActionLogByID, getAllActionLogs, getActionLogByUser } from '../controller/logging.js';
import {sendPushNotification}  from "../controller/push-notification.controller.js";
import { requireAuth } from "../middleware/authMiddleware.js";
import { getOverallStatistics } from '../controller/stastisticsController.js';



// Create an instance of Express Router
export const routers = express.Router();

// Initialize Multer middleware for file uploads
const upload = multer();

// Routes for missing person

routers
  .route("/createMissingPerson/:timeSinceDisappearance")

  .post(upload.any(), requireAuth, CreateMissingPerson);

// Routes for Logging
routers.route('/add_log_data').post(AddActionLogGateWay);
routers.route('/get-action-logs').get(getAllActionLogs);
routers.route('/get-action-log/:logId').get(getActionLogByID);
routers.route('/get-user-action-log/:userId').get(getActionLogByUser);
routers.route('/getStats').get(getOverallStatistics);

// Routes for Notification
routers.route('/send-notification').post(sendPushNotification);

