import express from 'express';
import multer from 'multer';
import { CreateMissingPerson } from "../controller/missingPersonController.js";

const upload = multer();

export const routers = express.Router();

routers.route('/createMissingPerson').post(upload.any(), CreateMissingPerson)