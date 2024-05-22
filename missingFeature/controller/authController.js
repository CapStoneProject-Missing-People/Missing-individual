import User from "../models/userModel.js";
import jwt from "jsonwebtoken";
import { config as dotenvConfig } from "dotenv";

// Load environment variables
dotenvConfig();

// Handle errors
const handleErrors = (err) => {
  let errors = { email: "", password: "" };

  // Incorrect email
  if (err.message === "incorrect email") {
    errors.email = "that email is not registered";
  }

  // Incorrect password
  if (err.message === "incorrect password") {
    errors.password = "that password is incorrect";
  }

  // Duplicate error code
  if (err.code === 11000 && err.keyPattern.phoneNo) {
    errors.email = "that phone number is already registered";
    console.log(err);
    return errors;
  }
  if (err.code === 11000 && err.keyPattern.email) {
    errors.email = "that email is already registered";
    console.log(err);
    return errors;
  }

  // Validate errors
  if (err.message.includes("user validation failed")) {
    Object.values(err.errors).forEach(({ properties }) => {
      errors[properties.path] = properties.message;
    });
  }
  console.log(err);
  return errors;
};

// Token expiration time
const maxAge = 3 * 24 * 60 * 60;

// Create JWT token
const createToken = (id) => {
  return jwt.sign({ id }, process.env.PRIV_KEY, {
    expiresIn: maxAge,
  });
};

export const signup_get = (req, res) => {
  res.send("signup");
};

export const signup_post = async (req, res) => {
  const { name, email, phoneNo, password, role } = req.body;
  try {
    const user = await User.create({ email, name, phoneNo, password, role });
    const token = createToken(user._id);
    res.cookie("jwt", token, {
      httpOnly: true,
      maxAge: maxAge * 1000,
    });
    res.status(201).json({ user, token: token });
  } catch (err) {
    const errors = handleErrors(err);
    res.status(400).json({ errors });
  }
};

export const login_get = (req, res) => {
  res.send("login");
};

export const login_post = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.login(email, password);
    const token = createToken(user._id);
    res.cookie("jwt", token, {
      httpOnly: true,
      maxAge: maxAge * 1000,
    });
    res.status(200).json({ user, token: token });
  } catch (err) {
    const errors = handleErrors(err);
    res.status(400).json({ errors });
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
    console.log("the error is:",errors);
    res.status(400).json({ errors });
  }
};

export const logout_get = (req, res) => {
  res.cookie("jwt", "", { maxAge: 1 });
  res.send("logged out");
};

export const protected_get = (req, res) => {
  res.send("protected route");
};

export const admin_get = (req, res) => {
  res.send("admin route");
};
