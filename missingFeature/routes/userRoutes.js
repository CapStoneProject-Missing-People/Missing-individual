import express from "express"
import { registerUser, loginUser, currentUser} from "../controller/userController.js"
import { validateToken } from "../middleware/validationTokenHandler.js"
const userRouter = express.Router()

userRouter.route('/register').post(registerUser)
userRouter.post('/login', loginUser)
userRouter.get('/current', validateToken, currentUser)
export default userRouter