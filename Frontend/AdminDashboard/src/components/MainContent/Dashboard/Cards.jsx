import React from 'react';
import { BsFillBellFill } from 'react-icons/bs';
import { IoMdArrowDropright } from "react-icons/io";
import { MdOutlineFeedback } from "react-icons/md";
import { GrUserAdmin } from "react-icons/gr";
import { NavLink } from 'react-router-dom';

function Cards() {
  return (
    <div className='main-cards'>
        <NavLink to='/log-management'>
            <div class="flex flex-col justify-between p-8 rounded-2xl bg-blue-400">
                <div class="font-inter text-xl flex items-center justify-between">
                    <h3>Log Management</h3>
                    <GrUserAdmin class="text-4xl"/>
                </div>
                <h1 class='font-inter text-xl'>10</h1>
            </div>
        </NavLink>
            
        <NavLink to='/feedbacks'>
            <div class="flex flex-col justify-between p-8 rounded-2xl bg-blue-400">
                <div class="font-inter text-xl flex items-center justify-between">
                    <h3>Feedback Collection</h3>
                    <MdOutlineFeedback class="text-4xl"/>
                </div>
                <h1 class='font-inter text-xl'>12</h1>
            </div>
        </NavLink>
        <NavLink to='/reports'>
            <div class="flex flex-col justify-between p-8 rounded-2xl bg-blue-400">
                <div class='font-inter text-xl flex items-center justify-between'>
                    <h3>Reporting Tools</h3>
                    <IoMdArrowDropright class="text-4xl"/>
                </div>
                <h1 class='font-inter text-xl'>Reports</h1>
            </div>
        </NavLink>   
        <NavLink to='/notifications'>
            <div class="flex flex-col justify-between p-8 rounded-2xl bg-blue-400">
                <div class="font-inter text-xl flex items-center justify-between">
                    <h3>Alerts</h3>
                    <BsFillBellFill class="text-4xl"/>
                </div>
                <h1 class='font-inter text-xl'>42</h1>
            </div>
        </NavLink>    
            
    </div>
  );
};

export default Cards;
