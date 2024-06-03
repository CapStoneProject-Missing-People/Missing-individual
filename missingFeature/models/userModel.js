import mongoose from "mongoose";
import pkg from "validator";
const { isEmail } = pkg;
import bcrypt from "bcrypt";

const { Schema, model } = mongoose;

const ROLES = {
  User: 2001,
  Admin: 3244,
  SuperAdmin: 5150,
};

const userSchema = new Schema(
  {
    email: {
      type: String,
      required: [true, "Please enter an email"],
      unique: true,
      validate: [isEmail, "Please enter a valid email"],
    },
    name: {
      type: String,
      required: [true, "Please enter your name"],
    },
    phoneNo: {
      type: String,
      required: [true, "Please enter a phone number"],
      match: [/^251[79]\d{8}$/, "please enter a valid phone number"],
      unique: true,
    },
    password: {
      type: String,
      required: [true, "Please enter a password"],
      minlength: [6, "Minimum password length is 6 characters"],
    },
    role: {
      type: Number,
      required: true,
      enum: Object.values(ROLES),
      default: ROLES.User, // Default role is "User"
    },
    permissions: {
      type: [String],
      enum: ["read", "update", "delete"],
      default: [],
    },
    fcmToken: {
      type: String,
      default: null,
    },
    notificationsEnabled: {
      type: Boolean,
      default: true,
    },
    fcmToken: {
      type: String,
      default: null,
    },
    notificationsEnabled: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Mongoose hook before document is saved to the database
userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) {
    return next();
  }

  const salt = await bcrypt.genSalt();
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Static method to login user
userSchema.statics.login = async function (email, password) {
  const user = await this.findOne({ email });
  if (user) {
    const auth = await bcrypt.compare(password, user.password);
    if (auth) {
      return user;
    }
    throw new Error("incorrect password");
  }
  throw new Error("incorrect email");
};

userSchema.statics.adminlogin = async function (email, password) {
  const user = await this.findOne({ email });
  if (user) {
    if (user.role !== 3244 && user.role !== 5150) {
      throw new Error("unauthorized access");
    }
    const auth = await bcrypt.compare(password, user.password);
    if (auth) {
      return user;
    }
    throw new Error("incorrect password");
  }
  throw new Error("incorrect email");
};
const User = model("user", userSchema);

//export default User;

export { User, ROLES };
