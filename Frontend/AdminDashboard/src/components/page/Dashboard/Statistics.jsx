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
  const [selectedYear, setSelectedYear] = useState(2024);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get(`http://localhost:4000/api/getStats?year=${selectedYear}`);
        setData(response.data);
      } catch (error) {
        console.error("There was an error fetching the statistics!", error);
      }
    };

    fetchData();
  }, [selectedYear]);  // Ensure the effect runs when selectedYear changes

  if (!data) return <div>Loading...</div>;

  const {
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
        backgroundColor: ["#ee4b4b", "#36A2EB", "#FFCE56"]
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
          "#ee4b4b",
          "#36A2EB",
          "#FFCE56",
          "#4BC0C0",
          "#9966FF",
          "#FF9F40"
        ]
      }
    ]
  };

  const handleYearChange = (event) => {
    const year = parseInt(event.target.value, 10);
    if (year >= 2024) {
      setSelectedYear(year);
    }
  };

  return (
    <div className="">
      <div className="flex items-center justify-between p-3 mb-4">
        <h3 className="font-bold">{chartType.charAt(0).toUpperCase() + chartType.slice(1)} Distribution</h3>
        <div className="flex items-center">
          {/* <input
            type="number"
            min="2024"
            value={selectedYear}
            onChange={handleYearChange}
            className="border border-gray-300 px-2 py-1 rounded"
            style={{ maxWidth: "80px" }}
          /> */}
        </div>
      </div>
      {chartType === "gender" && (
        <div className="chart-container p-2">
          <div className="max-w-sm mx-auto ">
            <Pie data={genderData} />
          </div>
        </div>
      )}
      {chartType === "status" && (
        <div className="chart-container p-2">
          <div className="max-w-sm mx-auto ">
            <Pie data={statusData} />
          </div>
        </div>
      )}
      {chartType === "age" && (
        <div className="chart-container p-1">
          <div className="w-full h-full" style={{ width: "100%", height: "341px" }}>
            <Bar
              data={ageData}
              options={{
                responsive: true,
                maintainAspectRatio: false
              }}
            />
          </div>
        </div>
      )}
    </div>
  );
};

export default Statistics;
