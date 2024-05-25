import { serviceAccount } from "../config/push-notification-key.js";
import admin from "firebase-admin";
import GuestFcmToken from "../models/guestNotification.js";
import User from "../models/userModel.js";
import Notification from "../models/NotificationModel.js";

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

    const response = await admin.messaging().send(message);
    console.log("Successfully sent FCM message:", response);
    return { success: true, response };
  } catch (error) {
    console.error("Error sending FCM message:", error);
    return { success: false, error };
  }
};

export const sendNotificationToAllUsersAndGuests = async (title, body, caseID) => {
  try {
    console.log("sending notification to all")
    const users = await User.find({ notificationsEnabled: true });
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
    const user = await User.findByIdAndUpdate(userId, { fcmToken }, { new: true });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    await DeleteGuestFCM(fcmToken);
    res.status(200).json({ message: "User FCM token updated successfully", user });
  } catch (error) {
    console.error('Error updating user FCM token:', error);
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
