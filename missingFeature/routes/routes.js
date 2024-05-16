// Import necessary modules
import express from 'express';
import multer from 'multer';
import { CreateMissingPerson } from "../controller/missingPersonController.js";
import { AddActionLogGateWay, getActionLogByID, getAllActionLogs, getActionLogByUser } from '../controller/logging.js';
import {sendPushNotification}  from "../controller/push-notification.controller.js";
import { requireAuth } from "../middleware/authMiddleware.js";



// Create an instance of Express Router
export const routes = express.Router();

// Initialize Multer middleware for file uploads
const upload = multer();

// Routes for missing person
routes
  .route("/createMissingPerson/:timeSinceDisappearance")
  .post(upload.any(), requireAuth, CreateMissingPerson);

// Routes for Logging
routes.route('/add_log_data').post(AddActionLogGateWay);
routes.route('/get-action-logs').get(getAllActionLogs);
routes.route('/get-action-log/:logId').get(getActionLogByID);
routes.route('/get-user-action-log/:userId').get(getActionLogByUser);

// Routes for Notification
routes.route('/send-notification').post(sendPushNotification);

