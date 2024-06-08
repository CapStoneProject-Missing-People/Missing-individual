import React, { useEffect, useState } from 'react';
import CardDataStats from './CardDataStats';
import Charts from './Charts';
import Statistics from './Statistics';
import axios from 'axios';
import { SiMicrosoftonenote } from "react-icons/si";
import { MdOutlineFeedback } from "react-icons/md";
import { GrUserAdmin } from 'react-icons/gr';
import { FaArrowsDownToPeople } from "react-icons/fa6";

function MainDashboard() {
  const [stats, setStats] = useState({
    logManagement: 0,
    feedbackCollection: 0,
    userManagement: 0,
    missingPeople: 0,
  });

  const [chartData, setChartData] = useState({
    loggedInUser: {},
    registeredUsers: {},
    userPosts: {},
  });
  const [logs, setLogs] = useState([]);

  useEffect(() => {
    const fetchLogs = async () => {
      try {
        const response = await axios.get('http://localhost:4000/api/get-action-logs');
        setLogs(response.data);
      } catch (error) {
        console.error('Error fetching logs:', error);
      }
    };

    fetchLogs();
  }, []);

  useEffect(() => {
    setStats((prevStats) => ({
      ...prevStats,
      logManagement: logs.length,
    }));
  }, [logs]);

  const [feedbackData, setFeedbackData] = useState([]);

  useEffect(() => {
    const fetchFeedback = async () => {
      try {
        const response = await axios.get('http://localhost:4000/api/getFeedBacks');
        setFeedbackData(response.data);
      } catch (error) {
        console.error('Error fetching feedback:', error);
      }
    };

    fetchFeedback();
  }, []);

  useEffect(() => {
    setStats((prevStats) => ({
      ...prevStats,
      feedbackCollection: feedbackData.length,
    }));
  }, [feedbackData]);

  useEffect(() => {
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

        setStats((prevStats) => ({
          ...prevStats,
          userManagement: userManagementResponse.data.length,
          missingPeople: featuresResponse.data.length,
        }));

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

        const registeredUsersData = aggregateData(userManagementResponse.data, 'createdAt');
        const userPostsData = aggregateData(featuresResponse.data, 'createdAt');
        const loggedInUserData = aggregateData(logInDataResponse.data, 'timestamp');

        setChartData({
          registeredUsers: registeredUsersData,
          userPosts: userPostsData,
          loggedInUser: loggedInUserData,
        });
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };

    fetchData();
  }, []);

  return (
    <main className="h-96">
      <div className="font-semibold mb-4">
        <h3>DASHBOARD</h3>
      </div>
      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 md:gap-6 xl:grid-cols-4 2xl:gap-7.5">
        <CardDataStats
          title="Log management"
          count={stats.logManagement}
          address="/log-management"
          icon={SiMicrosoftonenote}
          color="bg-indigo-400"
        />
        <CardDataStats
          title="Feedback Collection"
          count={stats.feedbackCollection}
          address="/feedbacks"
          icon={MdOutlineFeedback}
          color="bg-red-600"
        />
        <CardDataStats
          title="User Management"
          count={stats.userManagement}
          address="/user-management"
          icon={GrUserAdmin}
          color="bg-emerald-600"
        />
        <CardDataStats 
          title="Missing People" 
          count={stats.missingPeople} 
          address="/missing-people"
          icon={FaArrowsDownToPeople} 
          color="bg-orange-600"
        />
      </div>
      <div className="mt-10 grid grid-cols-1 gap-4 lg:grid-cols-2 2xl:gap-7.5">
        <div className="col-span-1">
          <Charts data={chartData} className="chart-container col-span-1" />
        </div>
        <div className="col-span-1">
          <div className="chart-container col-span-1 rounded-2xl shadow-md border border-stroke bg-white px-5 py-5 pt-7.5 pb-4.5 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:col-span-1 mt-3">
            <Statistics chartType="age" />
          </div>
        </div>
        <div className="col-span-1 ">
          <div className="chart-container col-span-1 rounded-2xl shadow-md border border-stroke bg-white px-5 py-5 pt-7.5 pb-4.5 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:col-span-1 mt-3">
            <Statistics chartType="gender" />
          </div>
        </div>
        <div className="col-span-1 mb-12">
          <div className="chart-container col-span-1 rounded-2xl shadow-md border border-stroke bg-white px-5 py-5 pt-7.5 pb-4.5 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:col-span-1 mt-3">
            <Statistics chartType="status" />
          </div>
        </div>
      </div>
      
    </main>
  );
}

export default MainDashboard;
