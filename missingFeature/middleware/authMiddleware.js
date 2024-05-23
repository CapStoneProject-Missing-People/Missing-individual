import jwt from "jsonwebtoken";
import User from "../models/userModel.js";
import { config as dotenvConfig } from "dotenv";

// Load environment variables
dotenvConfig();

// Middleware to require authentication
export const requireAuth = (req, res, next) => {
  //const token = req.cookies.jwt;
  // Check if JSON web token exists & is verified
  try {
    const authHeader = req.header("authorization");
    if (!authHeader)
      return res.status(401).json({ msg: "unauthorized login first" });
    const token = authHeader.split(" ")[1];
    if (token) {
      jwt.verify(token, process.env.PRIV_KEY, async (err, decodedToken) => {
        if (err) {
          console.log(err.message);
          return res.status(401).json({ msg: "unauthorized login first" });
        } else {
          try {
            let user = await User.findById(decodedToken.id);
            if (!user) {
              return res.status(401).json({ msg: "unauthorized login first" });
            }
            req.user = user._id;
            req.token = token;
            return next();
          } catch (error) {
            console.error(error.message);
            return next();
          }
        }
      });
    } else {
      return res.status(401).json({ msg: "unauthorized login first" });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

//middleware to check the request is coming from admin
export const isAdmin = (roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ msg: "you can't access this route" });
    }
    next();
  };
};
