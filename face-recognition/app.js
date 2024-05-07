import express from 'express';
import { connectToDb } from './db/conn.cjs';
import dotenv from "dotenv";
import router from "./routes/routes.js"; // Update import path

dotenv.config();

const app = express();

app.use(express.json());

app.use('/', router);

connectToDb()
    .then(() => {
        app.listen(process.env.PORT || 3000);
        console.log("DB connected and server is running.");
    })
    .catch((err) => {
        console.log(err);
    });
