import React, { useState, useEffect } from 'react';
import axios from 'axios';
import PersonCard from './PersonCard';

const PersonList = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
        const headers = {
          Authorization: `Bearer ${token}`,
        };
        const response = await axios.get("http://localhost:4000/api/features/getAll", { headers });
        const persons = response.data.map(person => ({
          _id: person._id,
          firstName: person.name.firstName,
        }));
        setData(persons);
        setLoading(false);
      } catch (error) {
        setError('Error fetching data');
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>{error}</div>;

  return (
    <div className="container mx-auto p-4">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {data.map(person => (
          <PersonCard key={person._id} person={person} />
        ))}
      </div>
    </div>
  );
};

export default PersonList;
