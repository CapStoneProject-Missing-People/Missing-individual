import express from "express"
import dotenv from "dotenv"
import errorHandler from "./middleware/errorHandler.js"
import { router } from "./routes/featureRouter.js"
import { connectionDb } from "./config/dbConnection.js"
import { routers } from './routes/routes.js';

// import { connectPg } from "./config/pgDbConnection.js"
dotenv.config()

connectionDb()
// connectPg();
const app = express()
const port = process.env.PORT

app.use(express.json())
app.use('/api/features', router)
// app.use('/api/users', router2)

app.use('/api', routers)
app.use(errorHandler)

app.listen(port, () => {
    console.log(`server listening on port ${port}`)
})


//6uiODPcv9KCzkj0Q