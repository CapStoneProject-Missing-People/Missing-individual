import React from 'react';

const FeedbackList = ({ feedbackData }) => {
  return (
    <div>
      <h2>Feedback List</h2>
      <ul>
        {feedbackData.map((feedback) => (
          <li key={feedback._id}>{feedback.feedback}</li>
        ))}
      </ul>
    </div>
  );
};

export default FeedbackList;
