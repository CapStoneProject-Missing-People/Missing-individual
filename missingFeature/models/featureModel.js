import mongoose from "mongoose";

const { Schema, model } = mongoose;


const attributes = Schema(
    {
        user_id: {
            type: String,
            required: true,
            ref: "User"
        },
        name: Schema({
            firstName: {
                type: String
            },
            middleName: {
                type: String,
            },
            lastName: {
                type: String,
            },
            _id: false
        }),
        age: {
            type: Number,
            required: true    
        },
        skin_color: {
                type: String,
                enum: ["fair", "black", "white", "tseyim"],
                required: true
        },
        clothing: Schema({
                upper: {
                    clothType: {
                        type: String,
                        enum: ["tshirt", "hoodie", "sweater", "sweetshirt"],
                        required: true
                    },
                    clothColor:{
                        type: String,
                        enum: ["red", "blue", "white", "black"],
                        required: true
                    }
                },
                lower: {
                    clothType: {
                        type: String,
                        enum: ["trouser", "short", "nothing", "boxer"],
                        required: true
                    },
                    clothColor:{
                        type: String,
                        enum: ["red", "blue", "white", "black"],
                        required: true
                    }
                },
                _id: false
        }),
        body_size: {
            type: String,
            enum: ["Thin","Average", "Muscular", "Overweight", "Obese", "Fit", "Athletic", "Curvy", "Petite"]
        },
        description: {
                type: String,
                required: false
        },
        inputHash: {
            type: String,
            required: true,
            unique: true
        }
});


export default model("Features", attributes);
