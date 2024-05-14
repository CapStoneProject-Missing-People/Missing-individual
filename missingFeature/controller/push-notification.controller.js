import { serviceAccount } from '../config/push-notification-key.js';
import admin from 'firebase-admin';


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});


export const sendPushNotification = async(req, res, next) => {
    try {
        const message = {
            notification: {
                title: req.body.title || "test notification", // Set a default title if none is provided
                body: req.body.body || "Notification Message" // Set a default message if none is provided
            },
            data: {
                orderId: req.body.orderId || "122737", // Include any custom data fields
                orderDate: new Date().toISOString() // Convert date to ISO string for consistent format
            },
            token: req.body.fcm_token
        };

        await admin.messaging().send(message)
            .then((response) => {
                console.log('Successfully sent FCM messages:', response);
                res.status(200).send({ message: "Notification Sent" });
            })
            .catch((error) => {
                console.error('Error sending FCM messages:', error);
                res.status(500).send({ message: "Error sending notification" });
            });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send({ message: "Internal Server Error" }); // Handle unexpected errors gracefully
    }
}

