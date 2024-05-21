import React, { useEffect, useState } from 'react';
import CardDataStats from './CardDataStats';
import Charts from './Charts';
import axios from 'axios';

function MainDashboard() {
  const [stats, setStats] = useState({
    logManagement: 0,
    feedbackCollection: 0,
    reportingTools: 0,
    alerts: 0,
  });

  const [chartData, setChartData] = useState({
    visitors: [],
    registeredUsers: [],
  });

  useEffect(() => {
    // Fetch data for each category and calculate the number of rows
    const fetchData = async () => {
      try {
        // const logManagementResponse = await axios.get('http://localhost:4000/api/get-action-logs');
        // const feedbackCollectionResponse = await axios.get('http://localhost:3000/api/feedback-collection');
        const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
        const headers = {
          Authorization: `Bearer ${token}`,
        };
        const userManagementResponse = await axios.get("http://localhost:4000/api/admin/getAll", { headers });
        // const alertsResponse = await axios.get('http://localhost:3000/api/alerts');

        setStats({
          logManagement: 5, //logManagementResponse.data.length,
          feedbackCollection: 8, //feedbackCollectionResponse.data.length,
          userManagement: userManagementResponse.data.length,
          alerts: 10, // alertsResponse.data.length,
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
        // Fetch chart data
        //const chartResponse = await axios.get('http://localhost:3000/api/chart-data');
        setChartData({
         // visitors: chartResponse.data.visitors,
          registeredUsers: monthlyRegisteredUsers,
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
      <div className="mt-4 grid grid-cols-12 gap-4 md:mt-6 md:gap-6 2xl:mt-7.5 2xl:gap-7.5">
        <Charts data={chartData} />
      </div>
    </main>
  );
}

export default MainDashboard;
