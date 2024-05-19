
import express from "express"
import dotenv from "dotenv"
import { userRouter } from "./routes/userRoutes.js";
import {routers} from "./routes/featureRouter.js"
import { profileRouter } from "./routes/profileRouter.js";
import { connectionDb } from "./config/dbConnection.js"
import { routes } from "./routes/routes.js";
import { adminRouters } from "./routes/adminRouter.js";
import cors from "cors";
// import cookieParser from "cookie-parser"
// import { requireAuth, checkUser } from "./middleware/authMiddleware"
dotenv.config()


dotenv.config();

const port = process.env.PORT || 4000;
const app = express();

connectionDb();

app.use(express.json());
app.use(cors());
app.use("/api/features", routers);
app.use("/api/users", userRouter);
app.use("/api/profile", profileRouter);
app.use("/api/admin", adminRouters);
app.use("/api", routes);

app.listen(port, () => {
  console.log(`server listening on port ${port}`);
});
