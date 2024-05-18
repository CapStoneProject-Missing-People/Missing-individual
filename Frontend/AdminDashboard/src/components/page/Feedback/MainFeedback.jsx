import React, { useState, useEffect } from 'react';
import FeedbackTable from './FeedbackTable';
import FeedbackList from './FeedbackList';
import Title from '../../pagename/Title';
import axios from 'axios';

const MainFeedback = () => {
  const [feedbackData, setFeedbackData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchFeedback = async () => {
      try {
        const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
        const response = await axios.get('/api/feedback', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setFeedbackData(response.data);
        setLoading(false);
      } catch (error) {
        console.error('Error fetching feedback data:', error);
        setLoading(false);
      }
    };

    fetchFeedback();
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className='h-96'>
      <Title pageName="Feedback" />
      <FeedbackList />
      <FeedbackTable feedbackData={feedbackData} />
    </div>
  );
};

export default MainFeedback;
