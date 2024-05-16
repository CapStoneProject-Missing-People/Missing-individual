import React from 'react';
import { GrUserAdmin } from "react-icons/gr";
import { NavLink } from 'react-router-dom';

const CardDataStats = ({ title, address, levelUp, levelDown, children }) => {
  return (
    <div className="rounded-2xl border border-stroke bg-white px-3 py-6 shadow-default dark:border-strokedark dark:bg-boxdark">
      <NavLink to={address}>
            <div >
                <div class="font-inter text-xl flex items-center justify-between">
                    <h3>{title}</h3>
                    <GrUserAdmin class="text-4xl"/>
                </div>
                <h1 class='font-inter text-xl'>10</h1>
            </div>
        </NavLink>
    </div>
  );
};

export default CardDataStats;
