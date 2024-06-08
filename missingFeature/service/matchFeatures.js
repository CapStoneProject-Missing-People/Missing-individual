import MatchingStatus from '../models/matchingStatus.js'; // Adjust the path as needed
import initializeFeaturesModel from '../models/featureModel.js';

export const matchFeatures = async (newFeatureData, timeSinceDisappearance, similarityScores) => {
  try {
    const Features = await initializeFeaturesModel(timeSinceDisappearance);
    const existingFeatures = await Features.find();

    let criteria = {};
    if (timeSinceDisappearance > 2) {
      criteria = {
        age: newFeatureData.age,
        "name.firstName": newFeatureData.name.firstName,
        "name.middleName": newFeatureData.name.middleName,
        "name.lastName": newFeatureData.name.lastName,
        gender: newFeatureData.gender,
        skin_color: newFeatureData.skin_color,
        body_size: newFeatureData.body_size,
        description: newFeatureData.description,
        lastSeenLocation: newFeatureData.lastSeenLocation,
        medicalInformation: newFeatureData.medicalInformation,
        circumstanceOfDisappearance: newFeatureData.circumstanceOfDisappearance
      };
    } else if (timeSinceDisappearance <= 2) {
      criteria = {
        age: newFeatureData.age,
        "name.firstName": newFeatureData.name.firstName,
        "name.middleName": newFeatureData.name.middleName,
        "name.lastName": newFeatureData.name.lastName,
        gender: newFeatureData.gender,
        skin_color: newFeatureData.skin_color,
        "clothing.upper.clothType": newFeatureData.clothing.upper.clothType,
        "clothing.upper.clothColor": newFeatureData.clothing.upper.clothColor,
        "clothing.lower.clothType": newFeatureData.clothing.lower.clothType,
        "clothing.lower.clothColor": newFeatureData.clothing.lower.clothColor,
        body_size: newFeatureData.body_size,
        description: newFeatureData.description
      };
    }

    const ageRanges = {
      "1-4": { $gte: 1, $lte: 4 },
      "5-10": { $gte: 5, $lte: 10 },
      "11-15": { $gte: 11, $lte: 15 },
      "16-20": { $gte: 16, $lte: 20 },
      "21-30": { $gte: 21, $lte: 30 },
      "31-40": { $gte: 31, $lte: 40 },
      "41-50": { $gte: 41, $lte: 50 },
      ">51": { $gt: 51 },
    };

    const response = [];
    if (existingFeatures.length < 2) {
      return { message: 'Nothing to compare' };
    }

    for (const feature of existingFeatures) {
      if (feature._id.equals(newFeatureData._id)) {
        continue;
      }

      const matchingStatus = { id: feature._id };
      let aggregateSimilarity = 0;
      let fieldCount = 0;
      let highSimilarityFieldCount = 0;

      for (const key in criteria) {
        const value = criteria[key];
        fieldCount++;

        if (key === "age") {
          const featureAge = feature.age;
          if (featureAge === value) {
            matchingStatus.age = 100;
          } else {
            const newReqAgeRange = Object.keys(ageRanges).find(range => ageRanges[range].$gte <= value && ageRanges[range].$lte >= value);
            const featureAgeRange = Object.keys(ageRanges).find(range => ageRanges[range].$gte <= featureAge && ageRanges[range].$lte >= featureAge);
            matchingStatus.age = newReqAgeRange === featureAgeRange ? 85 : 0;
          }
        } else if (key.startsWith("name.")) {
          var namePart = key.split(".")[1];
          matchingStatus[namePart] = feature.name[namePart] === value ? 100 : 0;
        } else if (key.startsWith("clothing.")) {
          const [_, clothingType, clothKey] = key.split(".");
          const featureClothing = feature.clothing[clothingType][clothKey];

          if ((featureClothing === "blue" && value === "light blue") || (featureClothing === "light blue" && value === "blue") ||
              (featureClothing === "yellow" && value === "orange") || (featureClothing === "orange" && value === "yellow")) {
            matchingStatus[`${clothingType}${clothKey.charAt(0).toUpperCase() + clothKey.slice(1)}`] = 85;
          } else {
            matchingStatus[`${clothingType}${clothKey.charAt(0).toUpperCase() + clothKey.slice(1)}`] = featureClothing === value ? 100 : 0;
          }
        } else {
          matchingStatus[key] = feature[key] === value ? 100 : 0;
        }

        if (key.startsWith('name.')) {
          aggregateSimilarity += matchingStatus[namePart];
        } else {
          aggregateSimilarity += matchingStatus[key];
        }
        
        if ((key.startsWith('name.') && matchingStatus[namePart] >= 85) || matchingStatus[key] >= 85) {
          highSimilarityFieldCount++;
        }
      }

      similarityScores.forEach((score) => {
        if (score.existingCaseId.equals(feature._id)) {
          const similarityScore = parseFloat((score.similarityScore).toFixed(2));
          matchingStatus.similarityScore = similarityScore;
          aggregateSimilarity += similarityScore;
          fieldCount++;
          if (similarityScore >= 85) {
            highSimilarityFieldCount++;
          }
        }
      });
      matchingStatus.aggregateSimilarity = parseFloat((aggregateSimilarity / fieldCount).toFixed(2));

      // Store matchingStatus in the new collection
      if(matchingStatus.aggregateSimilar) {
        await MatchingStatus.create({
          user_id: newFeatureData.user_id,
          newCaseId: newFeatureData._id,
          existingCaseId: feature._id,
          matchingStatus,
  });
}

      response.push(matchingStatus);
    }

    return response;
  } catch (error) {
    console.error("Error comparing features:", error);
    throw new Error("Error comparing features");
  }
};
