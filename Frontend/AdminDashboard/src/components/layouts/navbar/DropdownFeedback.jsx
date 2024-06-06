import { useEffect, useRef, useState } from 'react';
import { NavLink } from 'react-router-dom';
import { MdOutlineFeedback } from "react-icons/md";
import axios from 'axios';

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
        className={`absolute right-0 mt-10 h-80 w-56 px-2 flex flex-col rounded-lg border border-stroke bg-slate-300 shadow-default dark:border-strokedark dark:bg-boxdark sm:right-0 sm:w-80 z-50 ${
          dropdownOpen ? 'block' : 'hidden'
        }`}
      >
        <div className="px-4.5 py-3">
          <h5 className="text-sm font-medium text-slate-500">Feedbacks</h5>
        </div>
        <div className="px-4.5 py-3 overflow-y-auto">
          {feedbackData.length > 0 ? (
            feedbackData.map((feedback, index) => (
              
              <div key={index} className="mb-2">
                <p className="text-sm text-gray-700"><span className='font-medium text-gray-900'>Name: </span> {feedback.user_id.name}</p>
                <p className="text-sm mb-2 text-gray-700"><span className='font-medium text-gray-900'>Feedback: </span> {feedback.feedback}</p>
                <hr />
              </div>
            ))
          ) : (
            <p className="text-sm text-gray-700">No feedback available</p>
          )}
        </div>
      </div>
      {/* <!-- Dropdown End --> */}
    </li>
  );
};

export default DropdownFeedback;
