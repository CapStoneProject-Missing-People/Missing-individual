import React, { useRef, useEffect, useState } from 'react';
import { useReactToPrint } from 'react-to-print';
import Charts from "../Dashboard/Charts";
import Statistics from "../Dashboard/Statistics";
import { CSVLink } from "react-csv";
import axios from 'axios';

const Report = () => {
  const chartRef1 = useRef();
  const chartRef2 = useRef();
  const chartRef3 = useRef();
  const chartRef4 = useRef();
  const [chartData, setChartData] = useState({
    loggedInUser: [],
    registeredUsers: [],
    userPosts: [],
  });
  const [allData, setAllData] = useState(null);  // To store all fetched data
  const [selectedYear, setSelectedYear] = useState(2024);

  const aggregateData = (data, dateKey) => {
    return data.reduce((acc, item) => {
      const date = new Date(item[dateKey]);
      const yearMonth = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}`;
      if (!acc[yearMonth]) {
        acc[yearMonth] = 0;
      }
      acc[yearMonth] += 1;
      return acc;
    }, {});
  };

  const fetchData = async () => {
    try {
      const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
      const headers = {
        Authorization: `Bearer ${token}`,
      };

      const [userManagementResponse, featuresResponse, logInDataResponse] = await Promise.all([
        axios.get("http://localhost:4000/api/admin/getAllUsers", { headers }),
        axios.get("http://localhost:4000/api/admin/getAllPost", { headers }),
        axios.get("http://localhost:4000/api/admin/getLogInData", { headers }),
      ]);

      const fetchedData = {
        registeredUsers: userManagementResponse.data,
        userPosts: featuresResponse.data,
        loggedInUser: logInDataResponse.data,
      };

      setAllData(fetchedData);  // Store all fetched data
      filterDataByYear(fetchedData, selectedYear);  // Aggregate and set initial data
    } catch (error) {
      console.error('Error fetching data:', error);
    }
  };

  const filterDataByYear = (data, year) => {
    const filterByYear = (items, dateKey) => {
      return items.filter(item => new Date(item[dateKey]).getFullYear() === year);
    };

    const filteredData = {
      registeredUsers: aggregateData(filterByYear(data.registeredUsers, 'createdAt'), 'createdAt'),
      userPosts: aggregateData(filterByYear(data.userPosts, 'createdAt'), 'createdAt'),
      loggedInUser: aggregateData(filterByYear(data.loggedInUser, 'timestamp'), 'timestamp'),
    };

    setChartData(filteredData);
  };

  useEffect(() => {
    fetchData();
  }, []);

  useEffect(() => {
    if (allData) {
      filterDataByYear(allData, selectedYear);  // Aggregate and set data on year change
    }
  }, [selectedYear]);

  const handlePrintChart1 = useReactToPrint({
    content: () => chartRef1.current,
    documentTitle: 'Registered Users Chart',
  });

  const handlePrintChart2 = useReactToPrint({
    content: () => chartRef2.current,
    documentTitle: 'Age Distribution Chart',
  });

  const handlePrintChart3 = useReactToPrint({
    content: () => chartRef3.current,
    documentTitle: 'Gender Distribution Chart',
  });

  const handlePrintChart4 = useReactToPrint({
    content: () => chartRef4.current,
    documentTitle: 'Status Distribution Chart',
  });

  const csvData = [
    ["Month", "Registered Users", "User Posts", "Logged In Users"],
    ...Object.keys(chartData.registeredUsers).map(month => [
      month,
      chartData.registeredUsers[month],
      chartData.userPosts[month],
      chartData.loggedInUser[month]
    ])
  ];

  return (
    <div className="py-4 px-1">
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2 2xl:gap-7.5">
        <div className="col-span-1">
          <div ref={chartRef1} className="chart-container col-span-1 ">
            <Charts data={chartData} className="chart-container col-span-1" />
          </div>
          <button
            onClick={handlePrintChart1}
            className="mb-2 mr-4 bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-700"
          >
            Print as pdf
          </button>
          <CSVLink 
            data={csvData}
            filename={"report-data.csv"}
            className="mt-4 bg-green-500 text-white py-2.5 px-4 rounded hover:bg-green-700"
          >
            Export to CSV
          </CSVLink>
        </div>

        <div className="col-span-1">
          <div ref={chartRef2} className="chart-container col-span-1 rounded-2xl shadow-md border border-stroke bg-white px-5 pt-7.5 py-5 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:col-span-1 mt-3">
            <Statistics chartType="age" />
          </div>
          <button
            onClick={handlePrintChart2}
            className="mt-4 mb-2 bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-700"
          >
            Print as pdf
          </button>
        </div>

        <div className="col-span-1">
          <div ref={chartRef3} className="chart-container col-span-1 rounded-2xl shadow-md border border-stroke bg-white px-5 pt-7.5 pb-4.5 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:col-span-1 mt-3">
            <Statistics chartType="gender" />
          </div>
          <button
            onClick={handlePrintChart3}
            className="mt-4 bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-700"
          >
            Print as pdf
          </button>
        </div>

        <div className="col-span-1 mb-4">
          <div ref={chartRef4} className="chart-container col-span-1 rounded-2xl shadow-md border border-stroke bg-white px-5 pt-7.5 pb-4.5 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:col-span-1 mt-3">
            <Statistics chartType="status" />
          </div>
          <button
            onClick={handlePrintChart4}
            className="mt-4 bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-700"
          >
            Print as pdf
          </button>
        </div>
      </div>
      
      
    </div>
  );
};

export default Report;
