// Import necessary modules
import express from 'express';
import multer from 'multer';
import { CreateMissingPerson } from "../controller/missingPersonController.js";
import { AddActionLogGateWay, getActionLogByID, getAllActionLogs, getActionLogByUser } from '../controller/logging.js';
import {sendPushNotification, StoreGuestFCM, UpdateUserFCM, FetchNotifications, MarkNotificationAsRead, guestNotification, getPushNotificationDetail }  from "../controller/push-notification.controller.js";
import { requireAuth, isAdmin } from "../middleware/authMiddleware.js";
import { fetchAllMissingPeopleWithNames, updateImageBuffers } from '../controller/ImageController.js';
import { getOverallStatistics } from '../controller/stastisticsController.js';
import { GetMissingPerson, GetMergedId, UpdateMissingStatusToFound, UpdateMissingStatusToMissing, UpdateMissingStatusToPending } from '../controller/missingPersonController.js';

// Create an instance of Express Router
export const routers = express.Router();

// Initialize Multer middleware for file uploads
const upload = multer();

// Routes for missing person

routers
  .route("/createMissingPerson/:timeSinceDisappearance")

  .post(upload.any(), requireAuth, CreateMissingPerson);
routers.route('/get-missing-person').get(requireAuth, GetMissingPerson)
routers.route('/get-match/:caseId').get(GetMergedId)
routers.route('/change-staus-found/:caseId/status').put(requireAuth, UpdateMissingStatusToFound)
routers.route('/change-staus-missing/:caseId').put(requireAuth, UpdateMissingStatusToMissing)
routers.route('/change-staus-pending/:caseId').put(requireAuth, UpdateMissingStatusToPending)

// Routes for Logging
routers.route('/add_log_data').post(AddActionLogGateWay);
routers.route('/get-action-logs').get(getAllActionLogs);
routers.route('/get-action-log/:logId').get(getActionLogByID);
routers.route('/get-user-action-log/:userId').get(getActionLogByUser);
routers.route('/getStats').get(getOverallStatistics);

// Routes for Notification
routers.route('/send-notification').post(sendPushNotification);
routers.route('/store-guest-fcm-token').post(StoreGuestFCM);
routers.route('/update-user-fcm-token').put(requireAuth, UpdateUserFCM);
routers.route('/notificationToSingleUser').post(getPushNotificationDetail)

routers.route('/notifications').get(requireAuth, FetchNotifications)
routers.route('/notifications/:id/read').get(requireAuth, MarkNotificationAsRead)
routers.route('/guest-notifications').get(guestNotification)


routers.route('/get-images-with-names').get(requireAuth, isAdmin([3244, 5150]), fetchAllMissingPeopleWithNames);
routers.route('/update-image').put(upload.any(), requireAuth, isAdmin([3244, 5150]), updateImageBuffers);
