import Features from "../models/featureModel.js";
import crypto from 'crypto';
// import mongoose from "mongoose";

//@desc Get all features
//@route Get /api/features
//@access private
export const getFeatures = async (req, res) => {
    const features = await Features.find();
    res.status(200).json(features);
};


const calculateHash = (data) => {
    const hash = crypto.createHash('sha256');
    hash.update(JSON.stringify(data));
    return hash.digest('hex');
};

export const createFeature = async (req, res) => {
    try {
        const { age, skin_color, clothing: { upper: {upperClothType, upperClothColor}, lower: {lowerClothType, lowerClothColor} }, body_size, description } = req.body;

        // Calculate hash from the input data
        const inputHash = calculateHash({
            age,
            skin_color,
            clothing: {
                upper: { clothType: upperClothType, clothColor: upperClothColor },
                lower: { clothType: lowerClothType, clothColor: lowerClothColor }
            },
            body_size
        });

        // Check if a feature with the same hash already exists
        const existingFeature = await Features.findOne({ inputHash });

        // If a duplicate feature is found, return an error
        if (existingFeature) {
            return res.status(400).json({ error: 'Duplicate feature already exists' });
        }

        // If no duplicate feature is found, create a new feature
        const feature = await Features.create({
            age,
            skin_color,
            clothing: {
                upper: { clothType: upperClothType, clothColor: upperClothColor },
                lower: { clothType: lowerClothType, clothColor: lowerClothColor }
            },
            body_size,
            description,
            inputHash 
        });

        res.status(201).json({ feature });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
        console.error('Error creating feature:', error.message);
    }
};

const compareSentences = async(req, res) => {
    try{
        //Extract criteria from the request body
    }catch(error){

    }
}


export const compareFeature = async (req, res) => {
    try {
        // Extract criteria from the request body
        const { age, skin_color, clothing: { upper: {upperClothType, upperClothColor}, lower: {lowerClothType, lowerClothColor} }, body_size } = req.body;
        const criteria = {
            age,
            skin_color,
            'clothing.upper.clothType': upperClothType,
            'clothing.upper.clothColor': upperClothColor,
            'clothing.lower.clothType': lowerClothType,
            'clothing.lower.clothColor': lowerClothColor,
            body_size
        }

        // Find all matching cases in the database
        const matchingCases = await Features.find({}).lean();

        // Prepare response object
        const response = [];

        // Compare criteria with each matching case
        matchingCases.forEach((caseData) => {
            const matchingStatus = { id: caseData._id };
            for (const key in criteria) {
                const value = criteria[key];
                if (key.startsWith('clothing.')) {
                    const clothingParts = key.split('.'); // ['clothing', 'upper', 'clothType']
                    const clothingType = clothingParts[1]; // 'upper' or 'lower'
                    const clothKey = clothingParts[2]; // 'clothType' or 'clothColor'

                    // Check if the value matches the clothing type or color in the case
                    const caseClothType = caseData.clothing[clothingType][clothKey];
                    matchingStatus[`${clothingType} ${clothKey}`] = caseClothType === value ? 'match' : 'did not match';
                } else {
                    // Compare other attributes
                    matchingStatus[key] = caseData[key] === value ? 'match' : 'did not match';
                }
            }
            response.push(matchingStatus);
        });

        res.json({ matchingStatus: response });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
        console.error('Error comparing features:', error.message);
    }
}


//update features
export const updateFeature = async (req, res) => {
    try{
        const feature = await Features.findById(req.params.id)
        if(!feature){
        res.status(404)
        throw new Error('Feature not found')
        }

    // if(Feature.user_id.toString() !== req.user.id){
    //     res.status(403)
    //     throw new Error("User dont have permission to update other user Feature")
    // }
    
    const updatedFeature = await Features.findByIdAndUpdate(
        req.params.id,
        req.body,
        {new: true}
    )
    res.status(201).json(`Feature updated: ${updatedFeature}`); // Sending a meaningful response
    console.log('Feature updated successfully')
}catch(error){
    res.status(500).json({error: 'server error'})
    console.error(`Error updating feature ${error.message}`)
}}






//another logic for update feature

// export const updateFeature = async (req, res) => {
//     try {
//         const featureId = req.params.id;
//         const updateData = req.body;

//         // Find the existing feature
//         const existingFeature = await Features.findById(featureId);
//         if (!existingFeature) {
//             res.status(404);
//             throw new Error('Feature not found');
//         }

//         // Check if the request body is the same as the existing document
//         let isDifferent = false;
//         for (const key in updateData) {
//             if (updateData[key] !== existingFeature[key]) {
//                 isDifferent = true;
//                 break;
//             }
//         }

//         // If the request body is the same as the existing document, don't update
//         if (!isDifferent) {
//             console.log('Request body is the same as the existing document');
//             return res.status(200).json({ message: 'Feature is already up to date', feature: existingFeature });
//         }

//         // Perform the update if there are differences in the request body
//         const updatedFeature = await Features.findByIdAndUpdate(
//             featureId,
//             updateData,
//             { new: true }
//         );

//         // Check if any field is updated
//         const isUpdated = Object.keys(updateData).some(key => updateData[key] !== existingFeature[key]);

//         if (isUpdated) {
//             res.status(200).json({ message: 'Feature updated', feature: updatedFeature });
//             console.log('Feature updated successfully');
//         } else {
//             console.log('No fields are updated');
//             res.status(200).json({ message: 'No fields are updated', feature: existingFeature });
//         }
//     } catch (error) {
//         res.status(500).json({ error: 'Server error' });
//         console.error(`Error updating feature: ${error.message}`);
//     }
// };
