import mongoose from "mongoose";

const {Schema, model} = mongoose

const embeddingSchema = Schema({
    caseId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Feature'
    },
    embedding: [Number],
    similarity: [{
        caseId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'Feature'
        },
        similarityScore: Number
      }]

});

embeddingSchema.index({ embedding: '2d' }); // 2d index is suitable for arrays of numbers

export default model('embeddings', embeddingSchema)