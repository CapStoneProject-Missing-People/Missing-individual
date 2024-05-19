import mongoose from "mongoose";
import dotenv from "dotenv";
dotenv.config();

export const connectionDb = async () => {
  try {
    const connect = await mongoose.connect(process.env.dbUri);
    console.log(
      `Database connected to  ${connect.connection.host} Db Name: ${connect.connection.name}`
    );
  } catch (err) {
    console.log(`can not connect to DB: ${err}`);
    process.exit(1);
  }
};
