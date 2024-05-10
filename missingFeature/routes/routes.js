// Import necessary modules
import express from 'express';
import multer from 'multer';
import { CreateMissingPerson } from "../controller/missingPersonController.js";
import { AddActionLogGateWay, getActionLogByID, getAllActionLogs, getActionLogByUser } from '../controller/logging.js';
import { logApiMiddleware } from '../middleware/logApi.js';

// Create an instance of Express Router
export const routers = express.Router();

// Initialize Multer middleware for file uploads
const upload = multer();

// Route for missing person
routers.route('/createMissingPerson').post( upload.any(), CreateMissingPerson);

// Route for Logging
routers.route('/add_log_data').post(AddActionLogGateWay);
routers.route('/get-action-logs').get(getAllActionLogs);
routers.route('/get-action-log/:logId').get(getActionLogByID);
routers.route('/get-user-action-log/:userId').get(getActionLogByUser);
