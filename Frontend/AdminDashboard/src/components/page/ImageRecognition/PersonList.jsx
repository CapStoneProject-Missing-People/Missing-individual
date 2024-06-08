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
        const response = await axios.get("http://localhost:4000/api/get-images-with-names", { headers });

        const persons = response.data.map(item => ({
          _id: item.id,
          firstName: item.name,
          images: item.imageBuffers.map(buffer => ({
            id: item.id,
            url: URL.createObjectURL(new Blob([new Uint8Array(buffer.data)], { type: 'image/jpg' })),
          })),
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
