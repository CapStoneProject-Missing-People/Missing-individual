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
    res.status(200).json({ ...user._doc, token });
  } catch (err) {
    const errors = handleErrors(err);
    res.status(400).json({ errors });
  }
}

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
    console.log("the error is:",errors);
    res.status(400).json({ errors });
  }
};


    
export const getUserData = async (req, res) => {
  const user = await User.findById(req.user);
  res.json({ ...user._doc, token: req.user.token });
};
