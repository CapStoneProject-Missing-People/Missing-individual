import { pipeline }  from "@xenova/transformers"
import { getFeatures } from "../controller/featureController"

//Initialize the pipeline for the feature extraction
const generateEmbeddings = async () => {
    const piplineModel = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2')
    return pipelineModel
}


/// Function to generate embeddings from descriptions and store them in PostgreSQL
const processMissingCases = async () => {
    
    try{

        // Sample descriptions (replace with actual descriptions or retrieve from MongoDB)
        const descriptions = [
            'desc1',
            'desc2',
            'desc3'
        ]
        
        //Initialize pipeline for feature extraction
        const pipelineModel = await generateEmbeddings() 
        //Generate embedding for each description and store it in postgress
        for (const description of descriptions) {
            //generate embedding from description
            const output = await pipelineModel(description, { pooling: 'mean', normalize: true})
            const embedding = output.data;
            
            //store embedding in postgressSQL
            const query = 'INSERT INTO embeddings (embedding) VALUES ($1)'
            value = [embedding]
            await pgClient.query(query, values)
            
            console.log('embedding stored successfully')
        }
    }catch(error){
        console.log(`Error processing missing cases: ${error}`)
}
}