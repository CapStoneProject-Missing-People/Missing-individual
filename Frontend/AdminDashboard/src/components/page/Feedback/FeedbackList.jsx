import React, { useState, useEffect } from "react";
import { NavLink } from "react-router-dom";
import axios from 'axios';

const FeedbackList = () => {
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
    <ul className="flex flex-col overflow-y-auto">
      {feedbackData.map((item) => (
        <li key={item.id} className="border-t border-stroke py-3 px-4.5 hover:bg-gray-2 dark:border-strokedark dark:hover:bg-meta-4">
          <NavLink to="/feedbacks">
            <div className="flex gap-4.5">
              <div className="h-12 w-12 rounded-full overflow-hidden">
                <img
                  src={item.profileImage}
                  alt="profile cover"
                  className="h-full w-full rounded-tl-sm rounded-tr-sm object-cover object-center"
                />
              </div>
              <div className="flex flex-col ml-2">
                <h6 className="text-sm font-medium text-black dark:text-white">{item.name}</h6>
                <p className="text-sm">{item.feedback}</p>
                <p className="text-xs text-slate-400 mt-1">{item.timestamp}</p>
              </div>
            </div>
          </NavLink>
        </li>
      ))}
    </ul>
  );
};

export default FeedbackList;
