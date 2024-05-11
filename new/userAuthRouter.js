import { Router } from "express"
import { registerUser, getUser, loginUser, logoutUser} from "../controller/userAuthController.js"

export default userRouter = Router();

// router.route("/getUser").get(signup_get)
userRouter.route("/registerUser").post(registerUser)
userRouter.route("/getUser").get(getUser)
userRouter.route("/loginUser").post(loginUser)
userRouter.route("/logoutUser").get(logoutUser)

