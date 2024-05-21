import { serviceAccount } from '../config/push-notification-key.js';
import admin from 'firebase-admin';


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});


export const sendPushNotification = async (req, res, next) => {
    try {
        const { title, body, caseID, fcm_token } = req.body;
        const result = await sendPushNotificationFunc({
            title,
            body,
            caseID: String(caseID),
            orderDate: new Date().toISOString(),
            fcmToken: fcm_token
        });

        if (result.success) {
            res.status(200).send({ message: "Notification Sent" });
        } else {
            res.status(500).send({ message: "Error sending notification", error: result.error });
        }
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send({ message: "Internal Server Error" });
    }
};

export const sendPushNotificationFunc = async ({ title, body, caseID, fcmToken }) => {
    try {
        const message = {
            notification: {
                title: title,
                body: body
            },
            data: {
                caseID: caseID,
                orderDate: new Date().toISOString()
            },
            token: fcmToken
        };

        const response = await admin.messaging().send(message);
        console.log('Successfully sent FCM message:', response);
        return { success: true, response };
    } catch (error) {
        console.error('Error sending FCM message:', error);
        return { success: false, error };
    }
};