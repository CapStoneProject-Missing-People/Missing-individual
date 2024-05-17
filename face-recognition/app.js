import express from 'express';
import { connectToDb } from './db/conn.cjs';
import dotenv from "dotenv";
import router from "./routes/routes.js"; // Update import path

dotenv.config();

const app = express();

app.use(express.json( {limit: '10mb'}));
app.use(express.urlencoded({ limit: '10mb', extended: true }));


app.use('/', router);

const port = process.env.PORT || 5000
connectToDb()
    .then(() => {
        app.listen(port);
        console.log(`DB connected and server is running on port ${port}`);
    })
    .catch((err) => {
        console.log(err);
    });
