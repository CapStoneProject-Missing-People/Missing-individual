import cron from 'node-cron';
import Notification from '../models/NotificationModel';

// Schedule task to run every day at midnight
cron.schedule('0 0 * * *', async () => {
  try {
    await Notification.deleteOldNotifications();
    console.log('Old notifications deleted successfully');
  } catch (error) {
    console.error('Error deleting old notifications:', error);
  }
});
