import { User, ROLES } from "../models/userModel.js";
import jwt from "jsonwebtoken";
import { config as dotenvConfig } from "dotenv";
import { AddActionLog } from "./logging.js";

// Load environment variables
dotenvConfig();

// Handle errors
const handleErrors = (err) => {
  let errors = { email: "", password: "", role: "", phoneNo: "" };

  // Incorrect email
  if (err.message === "incorrect email") {
    errors.email = "that email is not registered";
    return errors.email;
  }

  // Incorrect password
  if (err.message === "incorrect password") {
    errors.password = "that password is incorrect";
    return errors.password;
  }

  // Duplicate error code
  if (err.code === 11000 && err.keyPattern.phoneNo) {
    errors.phoneNo = "that phone number is already registered";
    console.log(err);
    return errors.phoneNo;
  }
  if (err.code === 11000 && err.keyPattern.email) {
    errors.email = "that email is already registered";
    console.log(err);
    return errors.email;
  }

  // Cast error for role
  if (err.errors.role.name === "CastError" /* && err.path === 'role' */) {
    errors.role = "Invalid role value provided";
    console.log(err);
    return errors.role;
  }

  // Validate errors
  /* if (err.message.includes("user validation failed")) {
    Object.values(err.errors).forEach(({ properties }) => {
      console.log(properties.name);
      errors[properties.name] = properties.message;
      console.log(errors);
    });
  } */
};

// Token expiration time
const maxAge = 3 * 24 * 60 * 60;

// Create JWT token
const createToken = (id) => {
  return jwt.sign({ id }, process.env.PRIV_KEY, {
    expiresIn: maxAge,
  });
};

export const signup_post = async (req, res) => {
  const { name, email, phoneNo, password, role } = req.body;
  try {
    let assignedRole = ROLES.User; // Default to "User" role
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
    const token = createToken(user._id);
    res.cookie("jwt", token, {
      httpOnly: true,
      maxAge: maxAge * 1000,
    });
    await AddActionLog({
      action: "Signup",
      user_id: user._id || "",
      user_agent: req.headers["user-agent"],
      method: req.method,
      ip: req.socket.remoteAddress,
      status: 200,
      logLevel: "info",
    });
    res.status(201).json({ user, token: token });
  } catch (err) {
    AddActionLog({
      action: "Signup",
      user_id: email || "",
      user_agent: req.headers["User-Agent"],
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
    const token = createToken(user._id);
    //console.log(token);
    res.cookie("jwt", token, {
      httpOnly: true,
      maxAge: maxAge * 1000,
    });
    console.log(user._id);
    await AddActionLog({
      action: "Login",
      user_id: user._id || "",
      user_agent: req.headers["user-agent"],
      method: req.method,
      ip: req.socket.remoteAddress,
      status: 200,
      logLevel: "info",
    });

    res.status(200).json({ ...user._doc, token });
  } catch (err) {
    AddActionLog({
      action: "Login",
      user_id: email || "",
      user_agent: req.headers["User-Agent"],
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

export const logout_get = (req, res) => {
  res.send("logged out");
};

export const logout_get = (req, res) => {
  res.cookie("jwt", "", { maxAge: 1 });
  res.send("logged out");
};

export const token_valid = async (req, res) => {
  try {
    const authHeader = req.header("authorization");
    const token = authHeader.split(" ")[1];
    if (!token) return res.json(false);
    const verified = jwt.verify(token, process.env.PRIV_KEY);
    if (!verified) return res.json(false);
    const user = await User.findById(verified.id);
    if (!user) return res.json(false);
    res.json(true);
  } catch (err) {
    const errors = handleErrors(err);
    res.status(500).json({ errors });
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
    res.status(200).json({ user, token: token });
  } catch (err) {
    const errors = handleErrors(err);
    console.log("the error is:", errors);
    res.status(400).json({ errors });
  }
};

export const getUserData = async (req, res) => {
  const user = await User.findById(req.user);
  res.json({ ...user._doc, token: req.user.token });
};
