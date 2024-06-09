// Charts.js
import React, { useState, useEffect } from 'react';
import ReactApexChart from 'react-apexcharts';

const options = {
  legend: {
    show: false,
    position: 'top',
    horizontalAlign: 'left',
  },
  colors: ['#3C50E0', '#80CAEE', '#FFA500'], // Colors for each line
  chart: {
    fontFamily: 'Satoshi, sans-serif',
    height: 335,
    type: 'area',
    dropShadow: {
      enabled: true,
      color: '#623CEA14',
      top: 10,
      blur: 4,
      left: 0,
      opacity: 0.1,
    },
    toolbar: {
      show: false,
    },
  },
  responsive: [
    {
      breakpoint: 1024,
      options: {
        chart: {
          height: 300,
        },
      },
    },
    {
      breakpoint: 1366,
      options: {
        chart: {
          height: 350,
        },
      },
    },
  ],
  stroke: {
    width: [2, 2, 2],
    curve: 'straight',
  },
  grid: {
    xaxis: {
      lines: {
        show: true,
      },
    },
    yaxis: {
      lines: {
        show: true,
      },
    },
  },
  dataLabels: {
    enabled: false,
  },
  markers: {
    size: 4,
    colors: '#fff',
    strokeColors: ['#3056D3', '#80CAEE', '#FFA500'],
    strokeWidth: 3,
    strokeOpacity: 0.9,
    strokeDashArray: 0,
    fillOpacity: 1,
    discrete: [],
    hover: {
      size: undefined,
      sizeOffset: 5,
    },
  },
  xaxis: {
    type: 'category',
    categories: [],
    axisBorder: {
      show: false,
    },
    axisTicks: {
      show: false,
    },
  },
  yaxis: {
    title: {
      style: {
        fontSize: '0px',
      },
    },
    min: 0,
    max: 100,
  },
};

function Charts({ data }) {
  const [visibleSeries, setVisibleSeries] = useState({
    loggedInUser: false,
    registeredUsers: true,
    userPosts: false,
  });

  const [selectedYear, setSelectedYear] = useState(2024);

  const toggleSeries = (seriesName) => {
    setVisibleSeries((prevState) => ({
      ...prevState,
      [seriesName]: !prevState[seriesName],
    }));
  };

  const handleYearChange = (event) => {
    const year = parseInt(event.target.value, 10);
    if (year >= 2024) {
      setSelectedYear(year);
    }
  };

  const generateSeriesData = (seriesData) => {
    const monthCategories = [
      '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'
    ];
    options.xaxis.categories = monthCategories.map(month => `${selectedYear}-${month}`);

    return options.xaxis.categories.map(date => seriesData[date] || 0);
  };

  const series = [
    {
      name: 'Logged in user',
      data: visibleSeries.loggedInUser ? generateSeriesData(data.loggedInUser) : [],
    },
    {
      name: 'Registered Users',
      data: visibleSeries.registeredUsers ? generateSeriesData(data.registeredUsers) : [],
    },
    {
      name: 'User posts',
      data: visibleSeries.userPosts ? generateSeriesData(data.userPosts) : [],
    },
  ];

  useEffect(() => {
    setVisibleSeries({ loggedInUser: false, registeredUsers: true, userPosts: false });
  }, [selectedYear]);

  return (
    <div className="col-span-1 rounded-2xl shadow-md mb-4 border border-stroke bg-white px-5 pt-7.5 pb-4.5 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:col-span-1 mt-3">
      <div className="">
        <div className="flex w-full flex-wrap gap-3">
          <div className="flex min-w-[47.5%] md:min-w-[30%] cursor-pointer" onClick={() => toggleSeries('userPosts')}>
            <span className="mt-1 mr-2 flex h-4 w-full max-w-4 items-center justify-center rounded-full border border-primary">
              <span className="block bg-orange-400 h-2.5 w-full max-w-2.5 rounded-full bg-primary"></span>
            </span>
            <div className="w-full">
              <p className={`font-semibold ${visibleSeries.userPosts ? 'text-primary' : 'text-gray-400'}`}>
                <span>User<br /> posts </span>
              </p>
            </div>
          </div>
          <div className="flex min-w-[47.5%] md:min-w-[30%] cursor-pointer" onClick={() => toggleSeries('registeredUsers')}>
            <span className="mt-1 mr-2 flex h-4 w-full max-w-4 items-center justify-center rounded-full border border-secondary">
              <span className="block bg-cyan-400 h-2.5 w-full max-w-2.5 rounded-full bg-secondary"></span>
            </span>
            <div className="w-full">
              <p className={`font-semibold ${visibleSeries.registeredUsers ? 'text-secondary' : 'text-gray-400'}`}>
                <span>Registered <br />users <br /></span>
              </p>
            </div>
          </div>
          <div className="flex min-w-[47.5%] md:min-w-[30%] cursor-pointer" onClick={() => toggleSeries('loggedInUser')}>
            <span className="mt-1 mr-2 flex h-4 w-full max-w-4 items-center justify-center rounded-full border border-tertiary">
              <span className="block bg-sky-700 h-2.5 w-full max-w-2.5 rounded-full bg-tertiary"></span>
            </span>
            <div className="w-full">
              <p className={`font-semibold ${visibleSeries.loggedInUser ? 'text-tertiary' : 'text-gray-400'}`}>
                <span>Logged <br />in user <br /></span>
              </p>
            </div>
          </div>
        </div>
        <div className="flex items-center mt-2">
          <input
            type="number"
            min="2024"
            value={selectedYear}
            onChange={handleYearChange}
            className="border border-gray-300 px-2 py-1 rounded"
            style={{ maxWidth: '80px' }}
          />
        </div>
      </div>
      <div>
        <div id="chartOne" className="-ml-5">
          <ReactApexChart
            options={options}
            series={series}
            type="area"
            height={350}
          />
        </div>
      </div>
    </div>
  
  );
}

export default Charts;
