import { User, ROLES } from "../models/userModel.js";
import jwt from "jsonwebtoken";
import { config as dotenvConfig } from "dotenv";
import { AddActionLog } from "./logging.js";
import passwordValidator from "password-validator";

// Load environment variables
dotenvConfig();

// Handle errors
const handleErrors = (err) => {
  let errors = { email: "", password: "", role: "", phoneNo: "" };

  // Incorrect email
  if (err.message === "incorrect email") {
    errors.email = "That email is not registered";
    return errors.email;
  }

  // Incorrect password
  if (err.message === "incorrect password") {
    errors.password = "That password is incorrect";
    return errors.password;
  }

  if (err.message === "Password too short") {
    errors.password = "Minimum password length is 6 characters";
    return errors.password;
  }

  // Duplicate error code
  if (err.code === 11000 && err.keyPattern.phoneNo) {
    errors.phoneNo = "That phone number is already registered";
    console.log(err);
    return errors.phoneNo;
  }
  if (err.code === 11000 && err.keyPattern.email) {
    errors.email = "That email is already registered";
    console.log(err);
    return errors.email;
  }

  // Cast error for role

  // Validate errors
  /* if (err.message.includes("user validation failed")) {
    Object.values(err.errors).forEach(({ properties }) => {
      console.log(properties.name);
      errors[properties.name] = properties.message;
      console.log(errors);
    });
  } */
};

// Token expiration times
const accessTokenMaxAge = 15 * 60; // 15 minutes
const refreshTokenMaxAge = 7 * 24 * 60 * 60; // 7 days

// Create access token
const createAccessToken = (id) => {
  return jwt.sign({ id }, process.env.PRIV_KEY, {
    expiresIn: accessTokenMaxAge,
  });
};

// Create refresh token
const createRefreshToken = (id) => {
  return jwt.sign({ id }, process.env.REFRESH_TOKEN_SECRET, {
    expiresIn: refreshTokenMaxAge,
  });
};
const schema = new passwordValidator();
schema
  .is()
  .min(8)
  .is()
  .max(100)
  .has()
  .uppercase()
  .has()
  .lowercase()
  .has()
  .digits()
  .has()
  .not()
  .spaces();

export const signup_post = async (req, res) => {
  console.log('signing up')
  const { name, email, phoneNo, password, role } = req.body;
  try {
    if (!schema.validate(password)) {
      return res
        .status(400)
        .json({ message: "Password does not meet requirements" });
    }

    let assignedRole = ROLES.User;
    if (role && Object.values(ROLES).includes(role)) {
      assignedRole = role;
    }
    const user = await User.create({
      email,
      name,
      phoneNo,
      password,
      role: assignedRole,
    });

    const accessToken = createAccessToken(user._id);
    const refreshToken = createRefreshToken(user._id);

    // Save refresh token to user document
    user.refreshToken = refreshToken;
    await user.save();

    res.cookie("jwt", refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: refreshTokenMaxAge * 1000,
    });

    await AddActionLog({
      action: "Signup",
      user_id: user._id || "",
      user_agent: req.headers["user-agent"] || '',
      method: req.method,
      ip: req.socket.remoteAddress,
      status: 200,
      logLevel: "info",
    });

    res.status(201).json({
      user: {
        ...user.toObject(),
        password: undefined,
        refreshToken: undefined,
      },
      token: accessToken,
    });
  } catch (err) {
    AddActionLog({
      action: "Signup",
      user_id: email || "",
      user_agent: req.headers["User-Agent"] || "",
      method: req.method,
      ip: req.ip,
      status: 500,
      error: err.message || "Internal Server Error",
      logLevel: "error",
    });
    const errors = handleErrors(err);
    res.status(400).json({ errors });
  }
};

export const login_post = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.login(email, password);
    const accessToken = createAccessToken(user._id);
    const refreshToken = createRefreshToken(user._id);

    // Save refresh token to user document
    user.refreshToken = refreshToken;
    await user.save();


    res.cookie("jwt", refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: refreshTokenMaxAge * 1000,
    });

    await AddActionLog({
      action: "Login",
      user_id: user._id || "",
      user_agent: req.headers["user-agent"] || "",
      method: req.method,
      ip: req.socket.remoteAddress,
      status: 200,
      logLevel: "info",
    });
    

    res.status(200).json({
      ...user._doc,
      password: undefined,
      refreshToken: undefined,
      token: accessToken,
    });
  } catch (err) {
    AddActionLog({
      action: "Login",
      user_id: email || "",
      user_agent: req.headers["User-Agent"] || "",
      method: req.method,
      ip: req.ip,
      status: 500,
      error: err.message || "Internal Server Error",
      logLevel: "error",
    });
    const errors = handleErrors(err);
    res.status(400).json({ errors });
  }
};

export const refresh_token = async (req, res) => {
  try {
    console.log('refreshing')
    const refreshToken = req.cookies.jwt;

    if (!refreshToken) {
      return res.status(401).json({ message: "Refresh token not found" });
    }

    const decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);
    const user = await User.findById(decoded.id);

    if (!user || user.refreshToken !== refreshToken) {
      return res.status(403).json({ message: "Invalid refresh token" });
    }

    const accessToken = createAccessToken(user._id);
    const newRefreshToken = createRefreshToken(user._id);

    // Update refresh token in database
    user.refreshToken = newRefreshToken;
    await user.save();

    res.cookie("jwt", newRefreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: refreshTokenMaxAge * 1000,
    });

    res.json({ token: accessToken });
  } catch (err) {
    res.status(403).json({ message: "Invalid refresh token" });
  }
};

export const logout_get = async (req, res) => {
  const id = req.user.userId;
  try {
    // Clear refresh token in database
    const user = await User.findById(id);
    if (user) {
      user.refreshToken = null;
      await user.save();
    }

    res.clearCookie("jwt", {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
    });

    await AddActionLog({
      action: "Logout",
      user_id: id || "",
      user_agent: req.headers["user-agent"] || "",
      method: req.method,
      ip: req.socket.remoteAddress,
      status: 200,
      logLevel: "info",
    });

    res.status(200).json({ message: "Logged out successfully" });
  } catch (err) {
    res.status(500).json({ message: "Error during logout" });
  }
};

export const admin_login_post = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.adminlogin(email, password);
    const token = createToken(user._id);
    res.cookie("jwt", token, {
      httpOnly: true,
      maxAge: maxAge * 1000,
    });
    console.log("ip: " + req.ip);
    await AddActionLog({
      action: "admin_login",
      user_id: user._id || "",
      user_agent: req.headers["user-agent"] || "",
      method: req.method,
      ip: req.socket.remoteAddress,
      status: 200,
      logLevel: "info",
    });
    res.status(200).json({ user, token: token });
  } catch (err) {
    AddActionLog({
      action: "admin_login",
      user_id: email || "",
      user_agent: req.headers["User-Agent"] || "",
      method: req.method || "",
      ip: req.ip || "",
      status: 500,
      error: err.message || "Internal Server Error",
      logLevel: "error",
    });
    const errors = handleErrors(err);
    console.log("the error is:", err);
    res.status(400).json({ errors });
  }
};

export const getUserData = async (req, res) => {
  try {
    console.log('Fetching user data for user:', req.user);

    // Fetch the user from the database (optional, if req.user doesn't contain all fields)
    const user = await User.findById(req.user.userId).select('-password'); // Exclude password
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Return the user data along with the token
    res.json({
      id: user._id,
      name: user.name,
      email: user.email,
      phoneNo: user.phoneNo,
      token: req.user.token, // Include the token
    });
  } catch (err) {
    console.error('Error fetching user data:', err);
    res.status(500).json({ message: "Error fetching user data" });
  }
};
