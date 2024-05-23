import { useEffect, useRef, useState } from 'react';
import { NavLink } from 'react-router-dom';
import { IoMdNotifications } from 'react-icons/io';

const DropdownNotification = () => {
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [notifying, setNotifying] = useState(true);

  const trigger = useRef(null);
  const dropdown = useRef(null);

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
        to="#"
        className="relative flex h-8.5 w-8.5 items-center justify-center rounded-full border-[0.5px] border-stroke bg-gray hover:text-primary dark:border-strokedark dark:bg-meta-4 dark:text-white"
      >
        <span
          className={`absolute -top-0.5 right-0 z-1 h-2 w-2 rounded-full bg-meta-1 ${
            notifying === false ? 'hidden' : 'inline'
          }`}
        >
          <span className="absolute -z-1 inline-flex h-full w-full animate-ping rounded-full bg-meta-1 opacity-75"></span>
        </span>

        <IoMdNotifications className="fill-current duration-300 ease-in-out" size={25} />
      </NavLink>

      <div
        ref={dropdown}
        onFocus={() => setDropdownOpen(true)}
        onBlur={() => setDropdownOpen(false)}
        className={`absolute -right-27 mt-2.5 flex h-90 w-75 flex-col rounded-lg border border-stroke bg-white px-2 shadow-default dark:border-strokedark dark:bg-boxdark sm:right-0 sm:w-80 z-50 ${
          dropdownOpen === true ? 'block' : 'hidden'
        }`}
        style={{maxHeight:'22rem', overflow:'auto',zIndex:10}}
      >
        <div className="px-4.5 py-2">
          <h5 className="text-sm font-medium text-gray-500 font-Montserrat">Notification</h5>
        </div>

        <ul className="flex h-auto flex-col overflow-y-auto">
          <li>
            <NavLink
              className="flex flex-col gap-2.5 border-t border-stroke px-4.5 py-3 hover:bg-gray-2 dark:border-strokedark dark:hover:bg-meta-4"
              to="#"
            >
              <p className="text-sm  text-gray-500 font-Montserrat">
                <span className="text-black dark:text-white">Edit your information in a swipe</span>{' '} 
                Sint occaecat cupidatat non proident, sunt in culpa qui officia 
                deserunt mollit anim.
              </p>

              <p className="text-xs text-gray-500 ">12 May, 2025</p>
            </NavLink>
          </li>
          <li>
            <NavLink
              className="flex flex-col gap-2.5 border-t border-stroke px-4.5 py-3 hover:bg-gray-2 dark:border-strokedark dark:hover:bg-meta-4"
              to="#"
            >
              <p className="text-sm  text-gray-500">
                <span className="text-black dark:text-white">
                  It is a long established fact
                </span>{' '}
                that a reader will be distracted by the readable.
              </p>

              <p className="text-xs  text-gray-500">24 Feb, 2025</p>
            </NavLink>
          </li>
          <li>
            <NavLink
              className="flex flex-col gap-2.5 border-t border-stroke px-4.5 py-3 hover:bg-gray-2 dark:border-strokedark dark:hover:bg-meta-4"
              to="#"
            >
              <p className="text-sm  text-gray-500">
                <span className="text-black dark:text-white">
                  There are many variations
                </span>{' '}
                of passages of Lorem Ipsum available, but the majority have
                suffered
              </p>

              <p className="text-xs  text-gray-500">04 Jan, 2025</p>
            </NavLink>
          </li>
          <li>
            <NavLink
              className="flex flex-col gap-2.5 border-t border-stroke px-4.5 py-3 "
              to="#"
            >
              <p className="text-sm  text-gray-500">
                <span className="text-black dark:text-white">
                  There are many variations
                </span>{' '}
                of passages of Lorem Ipsum available, but the majority have
                suffered
              </p>

              <p className="text-xs  text-gray-500">01 Dec, 2024</p>
            </NavLink>
          </li>
        </ul>
      </div>
    </li>
  );
};

export default DropdownNotification;
