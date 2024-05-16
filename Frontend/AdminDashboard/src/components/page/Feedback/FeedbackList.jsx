import React, { useEffect, useState } from 'react';
import axios from 'axios';

const FeedbackList = () => {
  const [feedbackData, setFeedbackData] = useState([]);

  useEffect(() => {
    const fetchFeedbackData = async () => {
      try {
        const response = await axios.get('http://localhost:3000/api/feedbacks');
        // Ensure the data is an array
        setFeedbackData(Array.isArray(response.data) ? response.data : []);
      } catch (error) {
        console.error('Error fetching feedback data:', error);
        setFeedbackData([]); // Set as empty array in case of error
      }
    };

    fetchFeedbackData();
  }, []);

  if (!Array.isArray(feedbackData)) {
    console.error('Feedback data is not an array:', feedbackData);
    return null;
  }

  return (
    <div>
      <h2>Feedback List</h2>
      <ul>
        {feedbackData.map((feedback) => (
          <li key={feedback.id}>{feedback.message}</li>
        ))}
      </ul>
    </div>
  );
};

export default FeedbackList;
