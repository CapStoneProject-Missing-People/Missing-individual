import React from 'react'
import { NavLink } from 'react-router-dom';
import 
{BsGrid1X2Fill, BsMenuButtonWideFill, BsFillGearFill}
 from 'react-icons/bs'
import { LiaAccusoft } from "react-icons/lia";
import { MdOutlineFeedback } from "react-icons/md";
import { MdOutlineManageAccounts } from "react-icons/md";
import { FaArrowsDownToPeople } from "react-icons/fa6";
import { SiMicrosoftonenote } from "react-icons/si";
import { TbTextRecognition } from "react-icons/tb";

function Sidebar({openSidebarToggle, OpenSidebar}) {
  return (
    <aside id="sidebar" className={openSidebarToggle ? "sidebar-responsive": ""}>
        <div className='sidebar-title'>
            <div class='flex py-2'>
                <LiaAccusoft className='icon_header'/> FindMe
            </div>
            <span className='icon close_icon' onClick={OpenSidebar}>X</span>
        </div>
        <ul >
            <NavLink to='/dashboard' >
                <li class='font-inter font-semibold flex px-5 py-6 text-gray-700 active:text-indigo-600 hover:bg-gray-300 h-25'>
                    <BsGrid1X2Fill className='icon' /> Dashboard
                </li>
            </NavLink>
            <NavLink to='/user-management'>    
                <li class='font-inter font-semibold flex px-5 py-6 text-gray-700 active:text-indigo-600 hover:bg-gray-300 h-25'>
                    <MdOutlineManageAccounts className='icon'/> User Management
                </li>
            </NavLink>
            <NavLink to='/missing-people'>
                <li class='font-inter font-semibold flex px-5 py-6 text-gray-700 active:text-indigo-600 hover:bg-gray-300 h-25'>
                        <FaArrowsDownToPeople className='icon'/> Missing people
               </li>
            </NavLink>        
            <NavLink to='/log-management' >
                <li class='font-inter font-semibold flex px-5 py-6 text-gray-700 active:text-indigo-600 hover:bg-gray-300 h-25'>
                    <SiMicrosoftonenote className='icon'/> Log Management
                </li>
            </NavLink>
            <NavLink to='/facial-description'>    
                <li class='font-inter font-semibold flex px-5 py-6 text-gray-700 active:text-indigo-600 hover:bg-gray-300 h-25'>
                        <TbTextRecognition className='icon'/> Facial & Description    
                </li>
            </NavLink>
            <NavLink to='/reports'>
                <li class='font-inter font-semibold flex px-5 py-6 text-gray-700 active:text-indigo-600 hover:bg-gray-300 h-25'>
                        <BsMenuButtonWideFill className='icon'/> Reports                    
                </li>
            </NavLink>
            <NavLink to='/setting'>    
                <li class='font-inter font-semibold flex px-5 py-6 text-gray-700 active:text-indigo-600 hover:bg-gray-300 h-25'>
                    <BsFillGearFill className='icon'/> Setting
                </li>
            </NavLink>
            <NavLink to='/feedbacks'>
                <li class='font-inter font-semibold flex px-5 py-6 text-gray-700 active:text-indigo-600 hover:bg-gray-300 h-25'>
                    
                        <MdOutlineFeedback className='icon'/> Feedback
                </li>
            </NavLink>
        </ul>
    </aside>
  )
}

export default Sidebar