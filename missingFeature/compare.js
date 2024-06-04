import { compareFeatures } from './compareFunction'; // Adjust import as needed
import SimilarityScore from './similarityScoreModel'; // Adjust import as needed

export const createFeature = async (data, timeSinceDisappearance, userId) => {
  try {
    const Features = await initializeFeaturesModel(timeSinceDisappearance);
    const featureData = {
      ...data,
      inputHash: calculateHash(data),
      user_id: userId,
    };

    const existingFeature = await Features.findOne({ inputHash: featureData.inputHash });
    if (existingFeature) {
      return 'duplicate feature already exists';
    }

    featureData.timeSinceDisappearance = timeSinceDisappearance;
    const feature = await Features.create(featureData);
    console.log("Feature stored successfully");

    // Get the similarity scores
    const similarityScores = await compareFeatures(data, timeSinceDisappearance);

    // Prepare similarity details for the new feature
    const similarityDetails = similarityScores.map((score) => ({
      caseId: score.caseId,
      similarities: {
        firstName: score.firstName || 0,
        middleName: score.middleName || 0,
        lastName: score.lastName || 0,
        gender: score.gender || 0,
        skin_color: score.skin_color || 0,
        description: score.similarityScore || 0,
        lastSeenLocation: score.lastSeenLocation || 0,
        medicalInformation: score.medicalInformation || 0,
        circumstanceOfDisappearance: score.circumstanceOfDisappearance || 0,
      },
    }));

    // Store the similarity scores
    await SimilarityScore.create({
      caseId: feature._id,
      similarities: similarityDetails,
    });

    console.log("Similarity scores stored successfully");

    // Rest of the embedding logic
    const existingEmbeddings = await embeddings.find();
    const pipelineModel = await generateEmbeddings();
    const output = await pipelineModel(data.description, {
      pooling: "mean",
      normalize: true,
    });
    const embeddingData = output.data;
    const embeddingArray = [...embeddingData];

    if (existingEmbeddingsCount < 1) {
      await embeddings.create({
        caseId: feature._id,
        embedding: embeddingArray,
        similarity: {},
      });
      console.log("Initial embedding stored successfully");
    } else {
      const similarityScores = await existingEmbeddings.map(
        (existingEmbedding) => {
          const similarity = calculateSimilarity(
            embeddingData,
            existingEmbedding.embedding
          );
          return {
            existingCaseId: existingEmbedding.caseId,
            existingEmbeddingId: existingEmbedding._id,
            similarityScore: similarity * 100,
          };
        }
      );

      const similarityObjects = similarityScores.map((item) => ({
        CaseId: item.existingCaseId,
        existingEmbId: item.existingEmbeddingId,
        similarityScore: item.similarityScore,
      }));

      await embeddings.create({
        caseId: feature._id,
        embedding: embeddingArray,
        similarity: similarityObjects,
      });

      similarityScores.sort((a, b) => b.similarityScore - a.similarityScore);
      const topNSimilarities = similarityScores.slice(0, 10);
      for (let i = 0; i < topNSimilarities.length; i++) {
        const { existingCaseId, existingEmbeddingId, similarityScore } =
          topNSimilarities[i];
        await updateSimilarityField(
          feature._id,
          existingEmbeddingId,
          similarityScore
        );
      }
    }

    return { message: "Feature stored successfully", createdFeature: feature };

  } catch (error) {
    console.error("Error creating feature:", error);
    throw new Error(error);
  }
};
