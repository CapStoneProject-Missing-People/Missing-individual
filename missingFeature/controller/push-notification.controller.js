import { serviceAccount } from "../config/push-notification-key.js";
import admin from "firebase-admin";
import GuestFcmToken from "../models/guestNotification.js";
import { User } from "../models/userModel.js";
import Notification from "../models/NotificationModel.js";
import MissingPerson from "../models/missingPersonSchema.js";

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export const sendPushNotification = async (req, res, next) => {
  try {
    const { title, body, caseID, fcm_token } = req.body;
    const result = await sendPushNotificationFunc({
      title,
      body,
      caseID: String(caseID),
      orderDate: new Date().toISOString(),
      fcmToken: fcm_token,
    });

    if (result.success) {
      res.status(200).send({ message: "Notification Sent" });
    } else {
      res
        .status(500)
        .send({ message: "Error sending notification", error: result.error });
    }
  } catch (error) {
    console.error("Error:", error);
    res.status(500).send({ message: "Internal Server Error" });
  }
};

export const getPushNotificationDetail = async (req, res, next) => {
  try {
    const { title, body, caseId } = req.body;

    if (!title || !body || !caseId) {
      return res.status(400).send({ message: "Missing required fields" });
    }
    const missingPerson = await MissingPerson.findById(caseId);
    if (!missingPerson || !missingPerson.userID) {
      return res
        .status(404)
        .send({ message: "User associated with missing person not found" });
    }
    const userId = missingPerson.userID;
    console.log("missing id" + userId);
    const result = await sendNotificationToSingleUser(
      userId,
      title,
      body,
      caseId
    );

    if (result.success) {
      res.status(200).send({ message: result.message });
    } else {
      res.status(500).send({ message: result.message, error: result.error });
    }
  } catch (error) {
    console.error("Error:", error);
    res.status(500).send({ message: "Internal Server Error" });
  }
};

export const sendPushNotificationFunc = async ({
  title,
  body,
  caseID,
  fcmToken,
}) => {
  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        caseID: caseID,
        orderDate: new Date().toISOString(),
      },
      token: fcmToken,
    };
console.log(message);
    const response = await admin.messaging().send(message);
    console.log("Successfully sent FCM message:", response);
    return { success: true, response };
  } catch (error) {
    console.error("Error sending FCM message:", error);
    return { success: false, error };
  }
};

export const sendNotificationToAllUsersAndGuests = async (
  title,
  body,
  caseID
) => {
  try {
    console.log("sending notification to all");
    const users = await User.find({
      notificationsEnabled: true,
      fcmToken: { $ne: null },
    });
    const guestTokens = await GuestFcmToken.find({});

    const userTokens = users.map((user) => user.fcmToken);
    const guestTokensList = guestTokens.map((guest) => guest.fcmToken);

    for (const user of users) {
      const notification = new Notification({
        user: user._id,
        title,
        body,
        caseID,
      });
      await notification.save();

      await sendPushNotificationFunc({
        title,
        body,
        caseID,
        fcmToken: user.fcmToken,
      });
    }

    for (const guest of guestTokensList) {
      const notification = new Notification({
        guestToken: guest,
        title,
        body,
        caseID,
      });
      await notification.save();

      await sendPushNotificationFunc({
        title,
        body,
        caseID,
        fcmToken: guest,
      });
    }
  } catch (error) {
    console.error(
      "Error sending notifications to all users and guests:",
      error
    );
  }
};

export const sendNotificationToSingleUser = async (
  userId,
  title,
  body,
  caseID
) => {
  try {
    // Find the user by ID and check if notifications are enabled
    const user = await User.findById(userId);
    if (!user || !user.notificationsEnabled) {
      console.error("User not found or notifications not enabled");
      return {
        success: false,
        message: "User not found or notifications not enabled",
      };
    }

    // Get the user's FCM token
    const fcmToken = user.fcmToken;
    if (!fcmToken) {
      console.error("FCM token not found for the user");
      return { success: false, message: "FCM token not found for the user" };
    }

    // Create a new notification in the database
    const notification = new Notification({
      user: user._id,
      title,
      body,
      caseID,
    });
    await notification.save();

    // Send the push notification using the FCM token
    const result = await sendPushNotificationFunc({
      title,
      body,
      caseID,
      fcmToken,
    });

    if (result.success) {
      console.log("Notification sent successfully to the user");
      return {
        success: true,
        message: "Notification sent successfully to the user",
      };
    } else {
      console.error("Error sending notification:", result.error);
      return {
        success: false,
        message: "Error sending notification",
        error: result.error,
      };
    }
  } catch (error) {
    console.error("Error sending notification to single user:", error);
    return {
      success: false,
      message: "Internal Server Error",
      error: error.message,
    };
  }
};

export const StoreGuestFCM = async (req, res) => {
  const { fcmToken } = req.body;
  console.log("guest token", fcmToken);
  try {
    const guestToken = new GuestFcmToken({ fcmToken });
    await guestToken.save();
    await DelelteUserFCM(fcmToken);
    res.status(201).json({ message: "Guest FCM token stored successfully" });
  } catch (error) {
    console.error("Error storing guest FCM token:", error);
    res.status(500).json({ error: error.message });
  }
};

export const UpdateUserFCM = async (req, res) => {
  const { fcmToken } = req.body;
  console.log("update token", fcmToken);
  const userId = req.user.userId;
  console.log(userId);
  try {
    const user = await User.findByIdAndUpdate(
      userId,
      { fcmToken },
      { new: true }
    );
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    await DeleteGuestFCM(fcmToken);
    res
      .status(200)
      .json({ message: "User FCM token updated successfully", user });
  } catch (error) {
    console.error("Error updating user FCM token:", error);
    res.status(500).json({ error: error.message });
  }
};

const DeleteGuestFCM = async (fcmToken) => {
  console.log("deleting the guest token");
  try {
    await GuestFcmToken.findOneAndDelete({ fcmToken });
  } catch (error) {
    console.error("Error deleting guest FCM token:", error);
    throw new Error("Error deleting guest FCM token");
  }
};

const DelelteUserFCM = async (fcmToken) => {
  console.log("deleting the user fcm token");
  try {
    await User.findOneAndUpdate({ fcmToken }, { fcmToken: null });
  } catch (error) {
    console.error("Error deleting user FCM token:", error);
    throw new Error("Error deleting user FCM token");
  }
};

export const FetchNotifications = async (req, res) => {
  try {
    const userId = req.user.userId;
    console.log("the user: " + req.user.phone_number);
    const notifications = await Notification.find({ user: userId }).sort({
      createdAt: -1,
    });
    res.status(200).json(notifications);
  } catch (error) {
    console.error("Error fetching notifications for user:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const MarkNotificationAsRead = async (req, res) => {
  try {
    const notificationId = req.params.id;
    await Notification.findByIdAndUpdate(notificationId, { isRead: true });
    res.status(200).json({ message: "Notification marked as read" });
  } catch (error) {
    console.error("Error marking notification as read:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const guestNotification = async (req, res) => {
  try {
    const { fcmToken } = req.query;
    if (!fcmToken) {
      return res.status(400).json({ error: "FCM Token is required" });
    }
    const notifications = await Notification.find({
      guestToken: fcmToken,
    }).sort({ createdAt: -1 });
    res.status(200).json(notifications);
  } catch (error) {
    console.error("Error fetching notifications for guest:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};
