import React, { useEffect, useState } from "react";
import axios from "axios";
import { Bar, Pie } from "react-chartjs-2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
} from "chart.js";

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend, ArcElement);

const Statistics = ({ chartType }) => {
  const [data, setData] = useState(null);

  useEffect(() => {
    axios
      .get("http://localhost:4000/api/getStats")
      .then((response) => {
        setData(response.data);
      })
      .catch((error) => {
        console.error("There was an error fetching the statistics!", error);
      });
  }, []);

  if (!data) return <div>Loading...</div>;

  const {
    userCount,
    postCount,
    maleCount,
    femaleCount,
    ageRanges,
    missingCount,
    pendingCount,
    foundCount
  } = data;

  const genderData = {
    labels: ["Male", "Female"],
    datasets: [
      {
        label: "Gender Distribution",
        data: [maleCount, femaleCount],
        backgroundColor: ["#36A2EB", "#FF6384"]
      }
    ]
  };

  const statusData = {
    labels: ["Missing", "Found", "Pending"],
    datasets: [
      {
        label: "Status Distribution",
        data: [missingCount, foundCount, pendingCount],
        backgroundColor: ["#FF6384", "#36A2EB", "#FFCE56"]
      }
    ]
  };

  const ageData = {
    labels: Object.keys(ageRanges),
    datasets: [
      {
        label: "Age Distribution",
        data: Object.values(ageRanges),
        backgroundColor: [
          "#FF6384",
          "#36A2EB",
          "#FFCE56",
          "#4BC0C0",
          "#9966FF",
          "#FF9F40"
        ]
      }
    ]
  };

  return (
    <div>
      {chartType === "gender" && (
        <div className="border rounded shadow-sm bg-white p-3">
          <h3 className="font-bold">Gender Distribution</h3>
          <div className="max-w-sm mx-auto">
            <Pie data={genderData} />
          </div>
        </div>
      )}
      {chartType === "status" && (
        <div className="border rounded shadow-sm bg-white p-4">
          <h3 className="font-bold">Status Distribution</h3>
          <div className="max-w-sm mx-auto mb-2">
            <Pie data={statusData} />
          </div>
        </div>
      )}
      {chartType === "age" && (
        <div className="border rounded shadow-sm bg-white p-4">
          <h3 className="p-5 font-bold ">Age Distribution</h3>
          <div className="max-w-lg mx-auto mb-24">
            <Bar data={ageData} />
          </div>
        </div>
      )}
    </div>
  );
};

export default Statistics;
