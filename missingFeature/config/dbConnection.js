import mongoose from "mongoose"

export const connectionDb = async () => {
    try{
        const connect = await mongoose.connect(process.env.CONNECTION_STRING)
        console.log(`Database connected to  ${connect.connection.host} Db Name: ${connect.connection.name}`)
    }catch(err){
        console.log(`can not connect to DB: ${err}`)
        process.exit(1)
    }
}
