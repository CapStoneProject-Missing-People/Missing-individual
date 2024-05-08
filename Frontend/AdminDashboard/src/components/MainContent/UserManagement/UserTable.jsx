import React, { useState, useEffect } from 'react';
import userData from './info'; 

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
    }
  
    // Function to toggle admin privileges
    const toggleAdminPrivilege = (user) => {
      const updatedUser = { ...user, isAdmin: !user.isAdmin };
      const userIndex = users.findIndex(u => u.id === user.id);
      const updatedUsers = [...users];
      updatedUsers[userIndex] = updatedUser;
      setUsers(updatedUsers);
    }

  return (
    <div className="flex flex-col">
      <div className="overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div className="inline-block min-w-full py-2 sm:px-6 lg:px-8">
          <div className="overflow-hidden">
            <table className="min-w-full text-left text-sm font-light text-slate-600 dark:text-white">
              <thead className="border-b font-inter border-neutral-200 font-medium dark:border-white/10">
                <tr>
                  <th scope="col" className="px-6 py-4">#</th>
                  <th scope="col" className="px-4 py-4">First Name</th>
                  <th scope="col" className="px-4 py-4">Last Name</th>
                  <th scope="col" className="px-6 py-4">Email</th>
                  <th scope="col" className="px-12 py-4">Admin privilege</th>
                </tr>
              </thead>
              <tbody>
                {users.map(user => (
                  <tr
                    key={user.id}
                    className="border-b border-neutral-200 transition duration-300 ease-in-out hover:bg-neutral-100 dark:border-white/10 dark:hover:bg-neutral-600"
                    onClick={() => handleUserClick(user)}
                  >
                    <td className="whitespace-nowrap font-inter px-6 py-4 font-medium">{user.id}</td>
                    <td className="whitespace-nowrap font-inter px-6 py-4">{user.firstName}</td>
                    <td className="whitespace-nowrap font-inter px-6 py-4">{user.lastName}</td>
                    <td className="whitespace-nowrap font-inter px-6 py-4">{user.handle}</td>
                    <td className="whitespace-nowrap font-inter px-6 py-4">
                      <button
                        className={`${
                          user.isAdmin ? 'bg-green-500' : 'bg-red-500'
                        } hover:bg-opacity-75 text-white font-bold w-24 ml-6 py-2 px-4 rounded-full`}
                        onClick={(e) => {
                          e.stopPropagation(); // Prevent row click event from firing
                          toggleAdminPrivilege(user);
                        }}
                      >
                        {user.isAdmin ? 'On' : 'Off'}
                      </button>
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
}

export default UserTable;
