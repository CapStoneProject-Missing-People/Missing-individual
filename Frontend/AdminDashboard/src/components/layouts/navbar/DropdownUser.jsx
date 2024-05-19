import { useEffect, useRef, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { IoMdPerson } from 'react-icons/io';
import { IoSettingsOutline } from 'react-icons/io5';
import { CiLogout } from 'react-icons/ci';

const DropdownUser = ({ user }) => {
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const navigate = useNavigate();
  const trigger = useRef(null);
  const dropdown = useRef(null);

  // Function to handle logout
  const handleLogout = () => {
    // Clear the JWT token from cookies
    document.cookie = 'jwt=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    // Redirect to the login page
    navigate('/');
  };
  
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
    <div className="relative">
      <Link
        ref={trigger}
        onClick={() => setDropdownOpen(!dropdownOpen)}
        className="flex items-center gap-4"
        to="#"
      >
        <span className="hidden text-right lg:block">
          <span className="block text-sm text-white dark:text-white">
            {user.name} {user.lastName}
          </span>
          <span className="block text-xs">Admin</span>
        </span>

        <div className="h-8 w-8 mr-1 rounded-full bg-gray-300 text-gray-700 flex items-center justify-center font-bold">
          {user.profileImage ? (
            <img
              className="h-full w-full object-cover rounded-full"
              src={user.profileImage}
              alt="User"
            />
          ) : (
            <span className="text-white text-lg">{user.name.charAt(0)}</span>
          )}
        </div>
      </Link>

      {/* <!-- Dropdown Start --> */}
      <div
        ref={dropdown}
        className={`absolute right-0 mt-4 flex w-48 flex-col rounded-lg border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark ${
          dropdownOpen ? 'block' : 'hidden'
        }`}
      >
        <ul className="flex flex-col gap-5 border-b border-stroke px-6 py-7.5 dark:border-strokedark">
          <li>
            <Link
              to="/profiles"
              className="flex items-center gap-3.5 mt-3 text-sm font-medium duration-300 ease-in-out hover:text-primary lg:text-base"
            >
              <IoMdPerson className="fill-current text-black" size={22} />
              <span className="text-black text-base">My Profile</span>
            </Link>
          </li>
          <li>
            <Link
              to="/settings"
              className="flex items-center gap-3.5 mb-1
              text-sm font-medium duration-300 ease-in-out hover:text-primary lg:text-base"
              >
                <IoSettingsOutline className="fill-current text-black" size={22} />
                <span className="text-black text-base">Settings</span>
              </Link>
            </li>
          </ul>
          <button
            className="flex items-center text-black gap-3.5 px-6 py-4 text-sm font-medium duration-300 ease-in-out hover:text-primary lg:text-base"
            onClick={handleLogout}
          >
            <CiLogout className="fill-current text-black" size={22} />
            Log Out
          </button>
        </div>
        {/* <!-- Dropdown End --> */}
      </div>
    );
  };
  
  export default DropdownUser;
  