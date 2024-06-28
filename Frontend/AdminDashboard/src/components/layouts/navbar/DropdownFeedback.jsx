import { useEffect, useRef, useState } from 'react';
import { NavLink } from 'react-router-dom';
import { MdOutlineFeedback } from "react-icons/md";
import axios from 'axios';
import "../../../css/scrollbar.css"

const DropdownFeedback = () => {
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [notifying, setNotifying] = useState(true);
  const [feedbackData, setFeedbackData] = useState([]);

  const trigger = useRef(null);
  const dropdown = useRef(null);

  // Fetch feedback data
  useEffect(() => {
    const fetchFeedback = async () => {
      try {
        const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
        const response = await axios.get('http://localhost:4000/api/getFeedBacks', {
          headers: { Authorization: `Bearer ${token}` },
        });
        // Ensure the response data is an array
        if (Array.isArray(response.data)) {
          setFeedbackData(response.data.slice(0, 5)); // Get the first 5 feedbacks
        } else {
          setFeedbackData([]);
        }
      } catch (error) {
        console.error('Error fetching feedback data:', error);
        setFeedbackData([]);
      }
    };

    fetchFeedback();

    // Event listener for new feedback
    const handleNewFeedback = (event) => {
      setFeedbackData(prevFeedbackData => [event.detail, ...prevFeedbackData].slice(0, 5));
    };
    document.addEventListener('feedbackAdded', handleNewFeedback);

    return () => {
      document.removeEventListener('feedbackAdded', handleNewFeedback);
    };
  }, []);

  // Close on click outside
  useEffect(() => {
    const clickHandler = ({ target }) => {
      if (!dropdown.current) return;
      if (!dropdownOpen || dropdown.current.contains(target) || trigger.current.contains(target)) return;
      setDropdownOpen(false);
    };
    document.addEventListener('click', clickHandler);
    return () => document.removeEventListener('click', clickHandler);
  }, [dropdownOpen]);

  // Close if the esc key is pressed
  useEffect(() => {
    const keyHandler = ({ keyCode }) => {
      if (!dropdownOpen || keyCode !== 27) return;
      setDropdownOpen(false);
    };
    document.addEventListener('keydown', keyHandler);
    return () => document.removeEventListener('keydown', keyHandler);
  }, [dropdownOpen]);

  return (
    <li className="relative">
      <NavLink
        ref={trigger}
        onClick={() => {
          setNotifying(false);
          setDropdownOpen(!dropdownOpen);
        }}
        className="relative flex items-center justify-center rounded-full bg-gray hover:text-primary dark:border-strokedark dark:bg-meta-4 dark:text-white"
      >
        <span
          className={`absolute -top-0.5 -right-0.5 z-1 h-2 w-2 rounded-full bg-meta-1 ${
            notifying === false ? 'hidden' : 'inline'
          }`}
        >
          <span className="absolute -z-1 inline-flex h-full w-full animate-ping rounded-full bg-meta-1 opacity-75"></span>
        </span>

        <MdOutlineFeedback className="fill-current duration-300 ease-in-out" size={25} />
      </NavLink>

      {/* <!-- Dropdown Start --> */}
      <div
        ref={dropdown}
        className={`absolute right-0 scrollbar mt-2 w-72 max-h-52 overflow-y-auto rounded-lg border border-gray-200 bg-white shadow-lg dark:border-strokedark dark:bg-boxdark dark:shadow-dark transition-transform duration-300 ease-in-out ${
          dropdownOpen ? 'scale-100' : 'scale-0'
        } origin-top-right z-50`}
      >
        <div className="px-4 py-3 bg-blue-500 border-b border-gray-200 dark:border-strokedark">
          <h5 className="text-sm font-semibold text-gray-900 dark:text-gray-100">Feedbacks</h5>
        </div>
        <NavLink to="/feedbacks">
          <div className="px-4 py-3 space-y-3">
            {feedbackData.length > 0 ? (
              feedbackData.map((feedback, index) => (
                <div key={index} className="mb-2">
                  {feedback.user_id ? (
                    <>
                      <p className="text-sm text-gray-700 dark:text-gray-300">
                        <span className='font-semibold text-gray-900 dark:text-gray-100'>Name: </span> {feedback.user_id.name}
                      </p>
                      <p className="text-sm mb-2 text-gray-700 dark:text-gray-300">
                        <span className='font-semibold text-gray-900 dark:text-gray-100'>Feedback: </span> {feedback.feedback}
                      </p>
                    </>
                  ) : (
                    <p className="text-sm text-gray-700 dark:text-gray-300">
                      <span className='font-semibold text-gray-900 dark:text-gray-100'>Anonymous: </span> {feedback.feedback}
                    </p>
                  )}
                  <hr className="border-gray-200 dark:border-strokedark" />
                </div>
              ))
            ) : (
              <p className="text-sm text-gray-700 dark:text-gray-300">No feedback available</p>
            )}
          </div>
        </NavLink>
      </div>
      {/* <!-- Dropdown End --> */}
    </li>
  );
};

export default DropdownFeedback;
