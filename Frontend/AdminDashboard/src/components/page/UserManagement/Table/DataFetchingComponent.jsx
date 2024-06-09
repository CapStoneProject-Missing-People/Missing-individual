import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Table1 from './Table1'; // Make sure the path is correct

const DataFetchingComponent = () => {
  const [data, setData] = useState([]);
  
  useEffect(() => {
    const fetchData = async () => {
      try {
        const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
        const headers = {
          Authorization: `Bearer ${token}`,
        };
        const response = await axios.get("http://localhost:4000/api/admin/getAllUsers", { headers });
        setData(response.data);
      } catch (error) {
        console.error("Error fetching data: ", error);
      }
    };
    fetchData();
  }, []);
  return (
    <div>
      <Table1 data={data} />
    </div>
  );
};

export default DataFetchingComponent;
