import express from "express";
import dotenv from "dotenv";
import { routers } from "./routes/featureRouter.js";
import { userRouter } from "./routes/userRoutes.js";
import { profileRouter } from "./routes/profileRouter.js";
import { connectionDb } from "./config/dbConnection.js";
import { router } from "./routes/routes.js";
import { adminRouters } from "./routes/adminRouter.js";

dotenv.config();

const port = process.env.PORT || 4000;
const app = express();

connectionDb();

app.use(express.json());
app.use("/api/features", routers);
app.use("/api/users", userRouter);
app.use("/api/profile", profileRouter);
app.use("/api/admin", adminRouters);
app.use("/api", router);

// Handle 404 - Resource Not Found
app.use((req, res, next) => {
  res.status(404).json({ msg: "Route not found" });
});

app.listen(port, () => {
  console.log(`server listening on port ${port}`);
});
