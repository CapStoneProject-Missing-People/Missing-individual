import React, { useState } from "react";
import axios from 'axios';

const FeedbackTable = ({ feedbackData }) => {
  const [selectedResponses, setSelectedResponses] = useState([]);
  const [responseStatus, setResponseStatus] = useState({});

  const handleSelectResponse = (event, index) => {
    const updatedResponses = [...selectedResponses];
    updatedResponses[index] = event.target.value;
    setSelectedResponses(updatedResponses);
  };

  const handleSend = async (index) => {
    const selectedResponse = selectedResponses[index];
    if (selectedResponse) {
      try {
        const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
        const feedbackId = feedbackData[index].id;
        await axios.post(`/api/feedback/${feedbackId}/respond`, { response: selectedResponse }, {
          headers: { Authorization: `Bearer ${token}` },
        });
        setResponseStatus(prevState => ({ ...prevState, [index]: 'Success' }));
      } catch (error) {
        console.error('Error sending response:', error);
        setResponseStatus(prevState => ({ ...prevState, [index]: 'Failed' }));
      }
    } else {
      console.log('Please select a response before sending.');
    }
  };

  if (!feedbackData || feedbackData.length === 0) {
    return <div>No feedback data available</div>;
  }

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Name
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Feedback Message
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Response
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Action
            </th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {feedbackData.map((feedback, index) => (
            <tr key={index} className={index % 2 === 0 ? 'bg-gray-50' : 'bg-white'}>
              <td className="px-6 py-4 whitespace-nowrap">
                <div className="flex items-center">
                  <div className="flex-shrink-0 h-10 w-10">
                    <img className="h-10 w-10 rounded-full" src={feedback.profileImage} alt={feedback.name} />
                  </div>
                  <div className="ml-4">
                    <div className="text-sm font-medium text-gray-900">{feedback.name}</div>
                  </div>
                </div>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <div className="text-sm text-gray-900">{feedback.feedback}</div>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <select
                  className="form-select mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
                  value={selectedResponses[index] || ''}
                  onChange={(event) => handleSelectResponse(event, index)}
                >
                  <option value="">Select response</option>
                  <option value="Thank you">Thank you</option>
                  <option value="We will see it">We will see it</option>
                  <option value="Thank you for your feedback">Thank you for your feedback</option>
                </select>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <button
                  className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
                  onClick={() => handleSend(index)}
                  disabled={!selectedResponses[index]}
                >
                  Send
                </button>
                {responseStatus[index] && (
                  <span className={`ml-2 text-sm ${responseStatus[index] === 'Success' ? 'text-green-500' : 'text-red-500'}`}>
                    {responseStatus[index]}
                  </span>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default FeedbackTable;
