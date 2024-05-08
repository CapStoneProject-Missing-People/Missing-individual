import express from "express";
import dotenv from "dotenv";
import errorHandler from "./middleware/errorHandler.js";
import cookieParser from "cookie-parser";
import featureRouter from "./routes/featureRouter.js";
import { connectionDb } from "./config/dbConnection.js";
// import { connectPg } from "./config/pgDbConnection.js"
dotenv.config();

connectionDb();
// connectPg();
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());
app.use(cookieParser());

app.use(featureRouter);
// app.use('/api/users', router2)
//app.use(errorHandler);

app.listen(port, () => {
  console.log(`server listening on port ${port}`);
});
