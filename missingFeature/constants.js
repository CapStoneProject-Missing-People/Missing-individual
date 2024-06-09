import SimilarityScore from './similarityScoreModel'; // Import the new model

export const createFeature = async (data, timeSinceDisappearance, userId, res) => {
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

    const existingEmbeddingsCount = await embeddings.countDocuments();
    const similarityDetails = [];

    if (existingEmbeddingsCount > 0) {
      const existingEmbeddings = await embeddings.find();
      const pipelineModel = await generateEmbeddings();
      const output = await pipelineModel(data.description, {
        pooling: "mean",
        normalize: true,
      });
      const embeddingData = output.data;
      const embeddingArray = [...embeddingData];

      const similarityScores = existingEmbeddings.map(existingEmbedding => {
        const similarity = calculateSimilarity(embeddingData, existingEmbedding.embedding);
        return {
          existingCaseId: existingEmbedding.caseId,
          similarityScore: similarity * 100,
        };
      });

      similarityScores.sort((a, b) => b.similarityScore - a.similarityScore);

      for (let score of similarityScores) {
        const caseId = score.existingCaseId;
        const existingFeatureData = await Features.findById(caseId).lean();
        if (!existingFeatureData) continue;

        const similarityDetail = {
          caseId: caseId,
          similarities: {
            firstName: existingFeatureData.name.firstName === data.firstName ? 100 : 0,
            middleName: existingFeatureData.name.middleName === data.middleName ? 100 : 0,
            lastName: existingFeatureData.name.lastName === data.lastName ? 100 : 0,
            gender: existingFeatureData.gender === data.gender ? 100 : 0,
            skin_color: existingFeatureData.skin_color === data.skin_color ? 100 : 0,
            description: score.similarityScore,
            lastSeenLocation: existingFeatureData.lastSeenLocation === data.lastSeenLocation ? 100 : 0,
            medicalInformation: existingFeatureData.medicalInformation === data.medicalInformation ? 100 : 0,
            circumstanceOfDisappearance: existingFeatureData.circumstanceOfDisappearance === data.circumstanceOfDisappearance ? 100 : 0,
          },
        };

        similarityDetails.push(similarityDetail);
      }
    }

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

    return { message: "Feature stored successfully", createdFeature: feature, mergedFeature: mergedFeatures };

  } catch (error) {
    console.error("Error creating feature:", error);
    throw new Error(error);
  }
};
