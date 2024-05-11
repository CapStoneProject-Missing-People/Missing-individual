import bcrypt from "bcrypt";
import User from "../models/userModel.js";
import jwt from "jsonwebtoken"

//@desc register a user
//@route Get /api/users/register
//@access public
export const registerUser = async (req, res) => {
  try {

    const { email, password } = req.body;
    if (!email || !password) {
      res.status(400);
      throw new Error("all fields are mandatory");
    }
    
    const userAvailable = await User.findOne({ email });
    if (userAvailable) {
      res.status(400);
      throw new Error("User already registered");
    }
    
    //hashPassword
    const hashedPassowrd = await bcrypt.hash(password, 10);
    
    const user = await User.create({
      email,
      password: hashedPassowrd,
    });
    if (user) {
      res.status(200).json({ email: user.email });
    } else {
      res.status(400);
      throw new Error("user data is invalid");
    }
  } catch (error) {
    res.status(404).json(error.message)
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

  const user = await User.findOne({ email });
  let correctPassword = await bcrypt.compare(password, user.password)
  if (user && correctPassword) {
    const accessToken = jwt.sign(
      {
        user: {
          email: user.email,
          id: user._id
        },

      },
      process.env.ACCESS_TOKEN_SECRET,
      { expiresIn: "40m" }
    )

    res.status(200).json({ accessToken })
  }else{
    res.status(401)
    throw new Error ('email or password is incorrect')
  }

};

//@desc current user
//@route Get /api/users/current
//@access private
export const currentUser = async (req, res) => {
  res.json(req.user)
};
