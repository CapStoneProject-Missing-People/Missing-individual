import React, { useContext, useEffect, useState } from 'react';
import { FiSearch } from 'react-icons/fi';
import { MdMenu } from 'react-icons/md';
import { MenuContext } from '../../../context/MenuContext';
import DropdownFeedback from './DropdownFeedback';
import DropdownNotification from './DropdownNotification';
import DropdownUser from './DropdownUser';
import axios from 'axios';
import Cookies from 'js-cookie';

const Navbar = () => {
  const { toggleMenu } = useContext(MenuContext);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const token = Cookies.get('jwt');
        const response = await axios.get('http://localhost:4000/api/profile/current', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setUser(response.data);
        
      } catch (error) {
        console.error('Error fetching user data:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, []);

  // Default user data in case the actual user data isn't available yet
  const defaultUser = {
    firstName: 'Admin',
    lastName: 'User',
    profileImage: null
  };

  return (
    <nav className="bg-gray-800 text-white h-16 w-full z-[999] flex items-center justify-between px-2 md:px-2">
      {/* Left Sidebar */}
      <div className="flex items-center">
        <div
          className="w-8 h-8 bg-gray-600 flex p-2 rounded-full mr-3 focus:bg-gray-400 hover:bg-gray-500"
          onClick={toggleMenu}
        >
          <MdMenu />
        </div>
        <div className="hidden sm:block pl-2">
          <form action="https://formbold.com/s/unique_form_id" method="POST">
            <div className="relative">
              <button className="absolute left-0 top-1/2 -translate-y-1/2">
                <FiSearch
                  className="fill-body hover:fill-primary dark:fill-bodydark dark:hover:fill-primary"
                  width="20"
                  height="20"
                  viewBox="0 0 20 20"
                  fill="none"
                />
              </button>
              <input
                type="text"
                placeholder="Type to search..."
                className="w-full bg-transparent pl-9 pr-4 text-black focus:outline-none dark:text-white xl:w-125"
              />
            </div>
          </form>
        </div>
      </div>

      {/* Right Side */}
      <div className="flex items-center gap-3 2xsm:gap-7">
        <ul className="flex items-center gap-3 2xsm:gap-4 mr-2">
          <DropdownNotification />
          <DropdownFeedback />
        </ul>
        {loading ? (
          <div>Loading...</div>
        ) : (
          <DropdownUser user={user || defaultUser} />
        )}
      </div>
    </nav>
  );
};

export default Navbar;

