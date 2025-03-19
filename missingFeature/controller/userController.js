import bcrypt from "bcrypt";
import User from "../models/userModel.js";
import jwt from "jsonwebtoken";

//@desc register a user
//@route Get /api/users/register
//@access public
export const registerUser = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    res.status(400);
    throw new Error("all fields are mandatory");
  }

  const userAvailable = await User.findOne({ email });
  console.log(userAvailable);
  if (userAvailable) {
    res.status(400);
    throw new Error("User already registered");
  }

  //hashPassword
  const hashedPassowrd = await bcrypt.hash(password, 10);
  console.log(`hashed password: ${hashedPassowrd}`);

  const user = await User.create({
    email,
    password: hashedPassowrd,
  });
  console.log(`User created ${user}`);
  if (user) {
    res.status(200).json({ email: user.email });
  } else {
    res.status(400);
    throw new Error("user data is invalid");
  }
};

//@desc login a user
//@route Get /api/users/login
//@access public
export const loginUser = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    res.status(400);
    throw new Error("all fields are mandatory");
  }

  try {
    const user = await User.findOne({ email });
    if (!user) {
      res.status(401);
      throw new Error("email or password is incorrect");
    }

    const correctPassword = await bcrypt.compare(password, user.password);
    if (!correctPassword) {
      res.status(401);
      throw new Error("email or password is incorrect");
    }

    // Create tokens
    const accessToken = jwt.sign({ id: user._id }, process.env.PRIV_KEY, {
      expiresIn: accessTokenMaxAge,
    });

    const refreshToken = jwt.sign(
      { id: user._id },
      process.env.REFRESH_TOKEN_SECRET,
      { expiresIn: refreshTokenMaxAge }
    );

    // Save refresh token to user document
    user.refreshToken = refreshToken;
    user.lastLogin = new Date();
    await user.save();

    // Set refresh token as HTTP-only cookie
    res.cookie("jwt", refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: refreshTokenMaxAge * 1000,
    });

    // Send response with access token and user data
    res.status(200).json({
      accessToken,
      refreshToken, // Also sending in body for Flutter app
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        phoneNo: user.phoneNo,
        role: user.role,
        notificationsEnabled: user.notificationsEnabled,
      },
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(error.status || 500).json({
      message: error.message || "An error occurred during login",
    });
  }
};

//@desc current user
//@route Get /api/users/current
//@access private
export const currentUser = async (req, res) => {
  res.json(req.user);
};

// Token expiration times (matching authController.js)
const accessTokenMaxAge = 7 * 24 * 60 * 60; // 15 minutes
const refreshTokenMaxAge = 7 * 24 * 60 * 60; // 7 days
