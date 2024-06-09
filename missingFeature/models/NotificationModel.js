import mongoose from 'mongoose';

const { Schema, model } = mongoose;

const notificationSchema = new Schema(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "user",
    },
    guestToken: {
      type: String,
    },
    title: {
      type: String,
      required: true,
    },
    body: {
      type: String,
      required: true,
    },
    caseID: {
      type: String,
      required: true,
    },
    isRead: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

notificationSchema.statics.deleteOldNotifications = async function () {
  const fifteenSecondsAgo = new Date();
  fifteenSecondsAgo.setSeconds(fifteenSecondsAgo.getSeconds() - 86400);

  await this.deleteMany({ createdAt: { $lt: fifteenSecondsAgo } });
};

const Notification = model("notification", notificationSchema);

export default Notification;
