import React from 'react';
import FeedbackTable from './FeedbackTable';
import userData from './data'; 
import Title from '../../pagename/Title';

const MainFeedback = () => {
  return (
    <div className='h-96'>
      <Title pageName="Feedback"/>
      <FeedbackTable feedbackData={userData} />
    </div>
  );
};

export default MainFeedback;
