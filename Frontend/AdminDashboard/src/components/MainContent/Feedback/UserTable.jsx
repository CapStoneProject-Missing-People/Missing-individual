import React, { useState, useEffect } from 'react';
import userData from './datas';
import { HiOutlineChevronDown } from 'react-icons/hi';

const UserTable = () => {
  const [selectedUser, setSelectedUser] = useState(null);
  const [users, setUsers] = useState(() => {
    // Retrieve user data from local storage or use default data if not present
    const storedData = localStorage.getItem('userData');
    return storedData ? JSON.parse(storedData) : userData;
  });

  useEffect(() => {
    // Save user data to local storage whenever it changes
    localStorage.setItem('userData', JSON.stringify(users));
  }, [users]);

  const handleUserClick = (user) => {
    setSelectedUser(user);
  };

  // Function to handle selecting a response for admin
  const handleAdminResponse = (user, response) => {
    const updatedUser = { ...user, adminResponse: response };
    const userIndex = users.findIndex((u) => u.id === user.id);
    const updatedUsers = [...users];
    updatedUsers[userIndex] = updatedUser;
    setUsers(updatedUsers);
  };

  const toggleDropdown = (e) => {
    e.stopPropagation();
    const dropdown = e.currentTarget.nextElementSibling;
    dropdown.classList.toggle('hidden');
  };

  return (
    <div className="flex flex-col">
      <div className="overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div className="inline-block min-w-full py-2 sm:px-6 lg:px-8">
          <div className="overflow-hidden">
            <table className="min-w-full text-left text-sm font-light text-slate-600 dark:text-white">
              <thead className="border-b font-inter border-neutral-200 font-medium dark:border-white/10">
                <tr>
                  <th scope="col" className="px-6 py-4">
                    #
                  </th>
                  <th scope="col" className="px-4 py-4">
                    First Name
                  </th>
                  <th scope="col" className="px-4 py-4">
                    Last Name
                  </th>
                  <th scope="col" className="px-6 py-4">
                    Users Feedback
                  </th>
                  <th scope="col" className="px-12 py-4">
                    Admin Response
                  </th>
                </tr>
              </thead>
              <tbody>
                {users.map((user) => (
                  <tr
                    key={user.id}
                    className="border-b border-neutral-200 transition duration-300 ease-in-out hover:bg-neutral-100 dark:border-white/10 dark:hover:bg-neutral-600"
                    onClick={() => handleUserClick(user)}
                  >
                    <td className="whitespace-nowrap font-inter px-6 py-4 font-medium">
                      {user.id}
                    </td>
                    <td className="whitespace-nowrap font-inter px-6 py-4">
                      {user.firstName}
                    </td>
                    <td className="whitespace-nowrap font-inter px-6 py-4">
                      {user.lastName}
                    </td>
                    <td className="whitespace-nowrap font-inter px-6 py-4">
                      {user.handle}
                    </td>
                    <td className="whitespace-nowrap font-inter px-6 py-4">
                      <div className="relative">
                        <button
                          onClick={(e) => toggleDropdown(e)}
                          class="focus:outline-none hover:bg-opacity-75"
                        >
                          <HiOutlineChevronDown className="w-6 h-6 ml-16" />
                        </button>
                        <div className="absolute right-14 mt-2 w-53 bg-white rounded-md shadow-lg z-10 hidden">
                          <div className="py-1">
                            <button
                              onClick={() => {
                                handleAdminResponse(user, 'Thank you.');
                                toggleDropdown(e);
                              }}
                              className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 w-full text-left"
                            >
                              Thank you.
                            </button>
                            <button
                              onClick={() => {
                                handleAdminResponse(
                                  user,
                                  'We will see that, thank you for your feedback.'
                                );
                                toggleDropdown(e);
                              }}
                              className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 w-full text-left"
                            >
                              We will see that.
                            </button>
                            {/*We can Add more response options here */}
                          </div>
                        </div>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
};

export default UserTable;
