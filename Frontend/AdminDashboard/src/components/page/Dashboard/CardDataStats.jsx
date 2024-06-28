import React from 'react';
import { GrUserAdmin } from 'react-icons/gr';
import { NavLink } from 'react-router-dom';

const CardDataStats = ({ title, count, address,icon:Icon,color }) => {
  return (
    <div className="rounded-2xl border border-stroke bg-white px-3 py-6 shadow dark:border-strokedark dark:bg-boxdark">
      <NavLink to={address}>
        <div>
          <div className="font-inter text-xl flex items-center justify-between">
            <h3>{title}</h3>
            <div className={`h-12 w-12 rounded-full flex items-center ${color}`}>
              <Icon className="text-2xl ml-3" />
            </div>
          </div>
          <h1 className="font-inter text-xl">{count}</h1>
        </div>
      </NavLink>
    </div>
  );
};

export default CardDataStats;
