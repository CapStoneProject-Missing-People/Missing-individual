import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { IoCameraOutline } from 'react-icons/io5';
import Title from '../pagename/Title';

const Profile = () => {
  const [adminUser, setAdminUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({ name: '', email: '', phoneNo: '' });

  useEffect(() => {
    const fetchAdminUser = async () => {
      try {
        const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
        const response = await axios.get('http://localhost:4000/api/profile/current', {
          headers: {
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
        });
        setAdminUser(response.data);
        setFormData({ name: response.data.name, email: response.data.email, phoneNo: response.data.phoneNo });
      } catch (err) {
        setError(err.response ? err.response.data : err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchAdminUser();
  }, []);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
      const response = await axios.put('http://localhost:4000/api/profile/update', formData, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });
      setAdminUser(response.data);
      setFormData({
        name: response.data.name,
        email: response.data.email,
        phoneNo: response.data.phoneNo,
      });
      document.cookie = `user=${JSON.stringify(response.data)}; path=/;`;
      setIsEditing(false);
    } catch (err) {
      setError(err.response ? err.response.data : err.message);
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error fetching profile data: {JSON.stringify(error)}</div>;
  }

  if (!adminUser) {
    return <div>No profile data available</div>;
  }

  const initial = adminUser.name ? adminUser.name.charAt(0).toUpperCase() : '';

  return (
    <div className="h-96">
      <Title pageName="Profile" />

      <div className="overflow-hidden rounded-sm border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
        <div className="relative px-4 pb-6 text-center lg:pb-8 xl:pb-11.5">
          <div className="relative z-50 mx-auto mt-20 h-32 w-full max-w-32 backdrop-blur sm:h-44 sm:max-w-44 sm:p-3 overflow-hidden">
            <div className="relative drop-shadow-2">
              {adminUser.image ? (
                <img
                  src={adminUser.image}
                  alt="profile"
                  className="w-32 h-32 object-cover object-center rounded-full border-4 border-white shadow-lg"
                />
              ) : (
                <div className="w-32 h-32 flex items-center justify-center bg-gray-300 text-white text-4xl font-semibold rounded-full border-4 border-white shadow-lg">
                  {initial}
                </div>
              )}
              <label
                htmlFor="profile"
                className="absolute bottom-1 right-1 flex cursor-pointer items-center justify-center rounded-full bg-primary text-white hover:bg-opacity-90 sm:bottom-2 sm:right-2"
              >
                <span className="h-6 w-6 rounded-full bg-sky-800 overflow-hidden">
                  <IoCameraOutline className="ml-1 mt-1" />
                </span>
                <input
                  type="file"
                  name="profile"
                  id="profile"
                  className="sr-only"
                />
              </label>
            </div>
          </div>
          <div className="max-w-lg mx-auto bg-white drop-shadow-2xl rounded-md p-6">
            <h2 className="text-2xl font-semibold mb-4">Admin Profile</h2>
            <form onSubmit={handleSubmit}>
              <div className="mb-4">
                <label htmlFor="name" className="block text-left font-semibold mb-1">
                  Name
                </label>
                <input
                  type="text"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  disabled={!isEditing}
                  className={`w-full h-10 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring focus:ring-blue-200 ${!isEditing && 'bg-gray-100 cursor-not-allowed'}`}
                />
              </div>
              <div className="mb-4">
                <label htmlFor="email" className="block text-left font-semibold mb-1">
                  Email
                </label>
                <input
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  disabled={!isEditing}
                  className={`w-full h-10 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring focus:ring-blue-200 ${!isEditing && 'bg-gray-100 cursor-not-allowed'}`}
                />
              </div>
              <div className="mb-4">
                <label htmlFor="phoneNo" className="block text-left font-semibold mb-1">
                  Phone Number
                </label>
                <input
                  type="tel"
                  name="phoneNo"
                  value={formData.phoneNo}
                  onChange={handleChange}
                  disabled={!isEditing}
                  className={`w-full h-10 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring focus:ring-blue-200 ${!isEditing && 'bg-gray-100 cursor-not-allowed'}`}
                />
              </div>
              <div className="flex justify-end space-x-4">
                {isEditing ? (
                  <>
                    <button
                      type="button"
                      onClick={() => setIsEditing(false)}
                      className="bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600 focus:outline-none focus:bg-gray-600"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      className="bg-green-500 text-white px-4 py-2 rounded-md hover:bg-green-600 focus:outline-none focus:bg-green-600"
                    >
                      Save
                    </button>
                  </>
                ) : (
                  <button
                    type="button"
                    onClick={() => setIsEditing(true)}
                    className="mt-4 bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600 focus:outline-none focus:bg-blue-600"
                  >
                    Edit Profile
                  </button>
                )}
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Profile;
