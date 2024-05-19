const express = require("express");
const mongoose = require("mongoose");
const authRoutes = require("./router/authRoutes");
const cookieParser = require("cookie-parser");
const { requireAuth, checkUser } = require("./middleware/authMiddleware");
require("dotenv").config();

const app = express();

// middleware
app.use(express.static("public"));
app.use(express.json());
app.use(cookieParser());

// view engine
app.set("view engine", "ejs");

// database connection
const dbURI = process.env.dbUri;
mongoose
  .connect(dbURI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    useCreateIndex: true,
  })
  .then((result) => {app.listen(5000)
    console.log(`listning on port 5000`)
    console.log(`connected to db ${result.connection.name}`)
  })
  .catch((err) => console.log(err));

// routes
app.get("*", checkUser);
app.get("/", (req, res) => res.render("home"));
app.get("/protected", requireAuth, (req, res) => res.render("protected"));
app.use(authRoutes);
