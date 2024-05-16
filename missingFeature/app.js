import express from "express"
import dotenv from "dotenv"
import userRouter from "./routes/userRoutes.js"
import { router } from "./routes/featureRouter.js"
import { connectionDb } from "./config/dbConnection.js"
import { routers } from "./routes/routes.js";
// import cookieParser from "cookie-parser"
// import { requireAuth, checkUser } from "./middleware/authMiddleware"
dotenv.config()

const port = process.env.PORT
const app = express()
// app.use(cookieParser());

connectionDb()

app.use(express.json())
app.use('/api/features', router)
app.use('/api/users', userRouter)
app.use('/api', routers)

app.listen(port, () => {
    console.log(`server listening on port ${port}`)
})


//6uiODPcv9KCzkj0Q