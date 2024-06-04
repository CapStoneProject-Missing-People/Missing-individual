import React, { useEffect, useState } from 'react';
import CardDataStats from './CardDataStats';
import Charts from './Charts';
import Statistics from './Statistics';
import axios from 'axios';

function MainDashboard() {
  const [stats, setStats] = useState({
    logManagement: 0,
    feedbackCollection: 0,
    reportingTools: 0,
    alerts: 0,
  });

  const [chartData, setChartData] = useState({
    loggedInUser: [],
    registeredUsers: [],
    userPosts: [],
  });

  useEffect(() => {
    // Fetch data for each category and calculate the number of rows
    const fetchData = async () => {
      try {
        const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
        const headers = {
          Authorization: `Bearer ${token}`,
        };

        const [userManagementResponse, featuresResponse, logInDataResponse] = await Promise.all([
          axios.get("http://localhost:4000/api/admin/getAllUsers", { headers }),
          axios.get("http://localhost:4000/api/features/getAll", { headers }),
          axios.get("http://localhost:4000/api/admin/getLogInData", { headers }),
        ]);

        setStats({
          logManagement: 5, // Example static data, replace with real response if needed
          feedbackCollection: 8, // Example static data, replace with real response if needed
          userManagement: userManagementResponse.data.length,
          alerts: 10, // Example static data, replace with real response if needed
        });

        const registeredUsersData = userManagementResponse.data.map(user => ({
          createdAt: user.createdAt,
          registeredDate: new Date(user.createdAt).toLocaleDateString(), // Extract registration date
          registeredTime: new Date(user.createdAt).toLocaleTimeString(), // Extract registration time
        }));

        // Aggregate the number of users per month based on the registration date
        const monthlyRegisteredUsers = Array(12).fill(0); // Initialize an array with 12 zeros for each month
        registeredUsersData.forEach(user => {
          const registeredMonth = new Date(user.createdAt).getMonth(); // Extract month (0 = January, 11 = December)
          monthlyRegisteredUsers[registeredMonth] += 1;
        });

        const userPostsData = featuresResponse.data.map(post => ({
          createdAt: post.createdAt,
          postDate: new Date(post.createdAt).toLocaleDateString(), // Extract post date
          postTime: new Date(post.createdAt).toLocaleTimeString(), // Extract post time
        }));

        // Aggregate the number of posts per month based on the post date
        const monthlyUserPosts = Array(12).fill(0); // Initialize an array with 12 zeros for each month
        userPostsData.forEach(post => {
          const postMonth = new Date(post.createdAt).getMonth(); // Extract month (0 = January, 11 = December)
          monthlyUserPosts[postMonth] += 1;
        });

        const loggedInUserData = logInDataResponse.data.map(log => ({
          timestamp: log.timestamp,
          logInDate: new Date(log.timestamp).toLocaleDateString(), // Extract login date
          logInTime: new Date(log.timestamp).toLocaleTimeString(), // Extract login time
        }));

        // Aggregate the number of logins per month based on the login date
        const monthlyLoggedInUsers = Array(12).fill(0); // Initialize an array with 12 zeros for each month
        loggedInUserData.forEach(log => {
          const logMonth = new Date(log.timestamp).getMonth(); // Extract month (0 = January, 11 = December)
          monthlyLoggedInUsers[logMonth] += 1;
        });

        setChartData({
          registeredUsers: monthlyRegisteredUsers,
          userPosts: monthlyUserPosts,
          loggedInUser: monthlyLoggedInUsers,
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
        />
        <CardDataStats 
          title="Feedback Collection" 
          count={stats.feedbackCollection} 
          address="/feedbacks"
        />
        <CardDataStats 
          title="User Management" 
          count={stats.userManagement} 
          address="/user-management" 
        />
        <CardDataStats 
          title="Alerts" 
          count={stats.alerts} 
          address="/alerts" 
        />
      </div>
      <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6 2xl:gap-7.5">
        <Charts data={chartData} className="col-span-1" />
        <Statistics className="col-span-1" />
      </div>
    </main>
  );
}

export default MainDashboard;
