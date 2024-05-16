import React, { useEffect, useState } from 'react';
import axios from 'axios';

const Profile = () => {
  const [adminUser, setAdminUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchAdminUser = async () => {
      try {
        const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
        const response = await axios.get('http://localhost:3000/api/users/profile', {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });
        setAdminUser(response.data);
      } catch (err) {
        setError(err.response ? err.response.data : err.message);
        console.error('Error fetching admin user:', err.response ? err.response.data : err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchAdminUser();
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error fetching profile data: {JSON.stringify(error)}</div>;
  }

  if (!adminUser) {
    return <div>No profile data available</div>;
  }

  return (
    <div>
      <h1>{adminUser.name}</h1>
      <p>Email: {adminUser.email}</p>
      {/* Add more fields as necessary */}
    </div>
  );
};

export default Profile;
