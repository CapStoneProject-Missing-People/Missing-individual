import React, { useState } from 'react';
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
    categories: [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ],
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

  const toggleSeries = (seriesName) => {
    setVisibleSeries((prevState) => ({
      ...prevState,
      [seriesName]: !prevState[seriesName],
    }));
  };

  const series = [
    {
      name: 'Logged in user',
      data: visibleSeries.loggedInUser ? data.loggedInUser : [],
    },
    {
      name: 'Registered Users',
      data: visibleSeries.registeredUsers ? data.registeredUsers : [],
    },
    {
      name: 'User posts',
      data: visibleSeries.userPosts ? data.userPosts : [],
    },
  ];

  return (
    <div className="col-span-12 rounded-sm mb-5 border border-stroke bg-white px-5 pt-7.5 pb-5 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:col-span-8 mt-3">
      <div className="flex flex-wrap items-start justify-between gap-3 sm:flex-nowrap">
        <div className="flex w-full flex-wrap gap-3 sm:gap-5">
          <div className="flex min-w-47.5 cursor-pointer" onClick={() => toggleSeries('userPosts')}>
            <span className="mt-1 mr-2 flex h-4 w-full max-w-4 items-center justify-center rounded-full border border-primary">
              <span className="block bg-orange-400 h-2.5 w-full max-w-2.5 rounded-full bg-primary"></span>
            </span>
            <div className="w-full">
              <p className={`font-semibold ${visibleSeries.userPosts ? 'text-primary' : 'text-gray-400'}`}>User posts</p>
              <p className="text-sm font-medium">12.04.2022 - 12.05.2022</p>
            </div>
          </div>
          <div className="flex min-w-47.5 cursor-pointer" onClick={() => toggleSeries('registeredUsers')}>
            <span className="mt-1 mr-2 flex h-4 w-full max-w-4 items-center justify-center rounded-full border border-secondary">
              <span className="block bg-cyan-400 h-2.5 w-full max-w-2.5 rounded-full bg-secondary"></span>
            </span>
            <div className="w-full">
              <p className={`font-semibold ${visibleSeries.registeredUsers ? 'text-secondary' : 'text-gray-400'}`}>Registered users</p>
              <p className="text-sm font-medium">01.01.2024 - 31.12.2024</p>
            </div>
          </div>
          <div className="flex min-w-47.5 cursor-pointer" onClick={() => toggleSeries('loggedInUser')}>
            <span className="mt-1 mr-2 flex h-4 w-full max-w-4 items-center justify-center rounded-full border border-tertiary">
              <span className="block bg-sky-700 h-2.5 w-full max-w-2.5 rounded-full bg-tertiary"></span>
            </span>
            <div className="w-full">
              <p className={`font-semibold ${visibleSeries.loggedInUser ? 'text-tertiary' : 'text-gray-400'}`}>Logged in user</p>
              <p className="text-sm font-medium">01.01.2024 - 31.12.2024</p>
            </div>
          </div>
        </div>
        <div className="flex w-full max-w-45 justify-end">
          {/* <div className="inline-flex items-center rounded-md bg-whiter p-1.5 dark:bg-meta-4">
            <button className="rounded bg-white py-1 px-3 text-xs font-medium text-black shadow-card hover:bg-white hover:shadow-card dark:bg-boxdark dark:text-white dark:hover:bg-boxdark">
              Day
            </button>
            <button className="rounded py-1 px-3 text-xs font-medium text-black hover:bg-white hover:shadow-card dark:text-white dark:hover:bg-boxdark">
              Week
            </button>
            <button className="rounded py-1 px-3 text-xs font-medium text-black hover:bg-white hover:shadow-card dark:text-white dark:hover:bg-boxdark">
              Month
            </button>
          </div> */}
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
