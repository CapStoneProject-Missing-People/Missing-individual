import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table1 from './Table1'; // Make sure the path is correct

const DataFetchingComponent = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  
  useEffect(() => {
    const fetchData = async () => {
      try {
        const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
        const headers = {
          Authorization: `Bearer ${token}`,
        };
        const response = await axios.get("http://localhost:4000/api/features/getAll", { headers });
        setData(response.data);
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
    <div>
      <Table1 data={data} />
    </div>
  );
};

export default DataFetchingComponent;
