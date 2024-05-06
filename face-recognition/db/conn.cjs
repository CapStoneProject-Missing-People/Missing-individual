require('dotenv').config();

const mongoose = require('mongoose');

const connectToDb = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGO_URL, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
            useCreateIndex: true,
        });
        console.log(`Mongodb connected successfully on: ${conn.connection.host}`);
    } catch (error) {
        console.log(error);
        console.log("error: ", error);
        process.exit(1);
    }
}

module.exports = { connectToDb };
