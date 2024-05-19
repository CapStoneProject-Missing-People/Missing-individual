
import express from "express"
import dotenv from "dotenv"
import { userRouter } from "./routes/userRoutes.js";
import { featureRouter } from "./routes/featureRouter.js"

import { profileRouter } from "./routes/profileRouter.js";
import { connectionDb } from "./config/dbConnection.js"
import { routers } from "./routes/routes.js";
import { adminRouters } from "./routes/adminRouter.js";
import cors from "cors";
// import cookieParser from "cookie-parser"
// import { requireAuth, checkUser } from "./middleware/authMiddleware"
dotenv.config()


dotenv.config();

const port = process.env.PORT || 3000;
const app = express();

connectionDb();

app.use(express.json());

app.use(cors());
app.use("/api/features", featureRouter);
app.use("/api/users", userRouter);
app.use("/api/profile", profileRouter);
app.use("/api/admin", adminRouters);
app.use("/api", routers);


app.listen(port, () => {
  console.log(`server listening on port ${port}`);
});
