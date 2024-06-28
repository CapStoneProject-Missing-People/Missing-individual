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
      set: value => value.trim(), // Trims whitespace
    },
    name: {
      type: String,
      required: [true, "Please enter your name"],
      set: value => value.trim(), // Trims whitespace
    },
    phoneNo: {
      type: String,
      required: [true, "Please enter a phone number"],
      match: [/^0[79]\d{8}$/, "Please enter a valid phone number"],
      unique: true,
      set: value => value.trim(), // Trims whitespace
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
    if (password.length < 6) {
      throw new Error("Password too short");
    }
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
    if (user.role !== ROLES.Admin && user.role !== ROLES.SuperAdmin) {
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

const User = model("User", userSchema);

// export default User;

export { User, ROLES };
