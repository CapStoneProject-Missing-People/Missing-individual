import express from "express";
import mongoose from "mongoose";
import { userRouter } from "./routes/authRoutes.js";

const PORT = process.env.PORT || 3000;
const app = express();

app.use(express.json());
app.use("/api/users", userRouter);

const DB = "mongodb://0.0.0.0:27017/flutter";

mongoose
  .connect(DB)
  .then(() => {
    console.log("Connection Successful");
  })
  .catch((e) => {
    console.log(e);
  });

app.listen(PORT, "0.0.0.0", () => {
  console.log(`connected at port ${PORT}`);
});
