// Import necessary modules
import express from 'express';
import multer from 'multer';
import { CreateMissingPerson } from "../controller/missingPersonController.js";

// Create an instance of Express Router
export const routers = express.Router();

// Initialize Multer middleware for file uploads
const upload = multer();

// Define route with middleware chain
routers.route('/createMissingPerson').post( upload.any(), CreateMissingPerson);

