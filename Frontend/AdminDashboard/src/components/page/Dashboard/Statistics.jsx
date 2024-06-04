import React, { useEffect, useState } from "react";
import axios from "axios";
import { Bar, Pie } from "react-chartjs-2";
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend, ArcElement } from "chart.js";

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend, ArcElement);

const Statistics = () => {
  const [data, setData] = useState(null);

  useEffect(() => {
    axios.get("http://localhost:4000/api/getStats")
      .then(response => {
        setData(response.data);
      })
      .catch(error => {
        console.error("There was an error fetching the statistics!", error);
      });
  }, []);

  if (!data) return <div>Loading...</div>;

  const { userCount, postCount, maleCount, femaleCount, ageRanges, missingCount, pendingCount, foundCount } = data;

  const genderData = {
    labels: ["Male", "Female"],
    datasets: [
      {
        label: "Gender Distribution",
        data: [maleCount, femaleCount],
        backgroundColor: ["#36A2EB", "#FF6384"],
      },
    ],
  };

  const statusData = {
    labels: ["Missing", "Found", "Pending"],
    datasets: [
      {
        label: "Status Distribution",
        data: [missingCount, foundCount, pendingCount],
        backgroundColor: ["#FF6384", "#36A2EB", "#FFCE56"],
      },
    ],
  };

  const ageData = {
    labels: Object.keys(ageRanges),
    datasets: [
      {
        label: "Age Distribution",
        data: Object.values(ageRanges),
        backgroundColor: [
          "#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0", "#9966FF", "#FF9F40"
        ],
      },
    ],
  };

  return (
    <div>
      <h2>Statistics</h2>
      <div>
        <h3>Total Users: {userCount}</h3>
        <h3>Total Posts: {postCount}</h3>
      </div>
      <div>
        <h3>Gender Distribution</h3>
        <Pie data={genderData} />
      </div>
      <div>
        <h3>Status Distribution</h3>
        <Pie data={statusData} />
      </div>
      <div>
        <h3>Age Distribution</h3>
        <Bar data={ageData} />
      </div>
    </div>
  );
};

export default Statistics;