import { useEffect, useRef, useState } from 'react';
import { NavLink } from 'react-router-dom';
import { FaMessage } from 'react-icons/fa6';
import userSix from '../../../images/user/userImage-min.png';
import { MdOutlineFeedback } from "react-icons/md";
import FeedbackList from '../../page/Feedback/FeedbackList';
import userData from '../../page/Feedback/data';

const DropdownFeedback = () => {
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [notifying, setNotifying] = useState(true);

  const trigger = useRef(null);
  const dropdown = useRef(null);

  // close on click outside
  useEffect(() => {
    const clickHandler = ({ target }) => {
      if (!dropdown.current) return;
      if (!dropdownOpen || dropdown.current.contains(target) || trigger.current.contains(target)) return;
      setDropdownOpen(false);
    };
    document.addEventListener('click', clickHandler);
    return () => document.removeEventListener('click', clickHandler);
  }, [dropdownOpen]);

  // close if the esc key is pressed
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

        <FeedbackList feedbackData={userData}/>
      </div>
      {/* <!-- Dropdown End --> */}
    </li>
  );
};

export default DropdownFeedback;
