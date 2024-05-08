import React from 'react'
import 
 {BsFillBellFill, BsPersonCircle, BsSearch, BsJustify}
 from 'react-icons/bs'
import { MdOutlineFeedback } from "react-icons/md";
import { NavLink } from 'react-router-dom';

function Header({OpenSidebar}) {
  return (
    <header className='header'>
        <div className='menu-icon'>
            <BsJustify className='icon' onClick={OpenSidebar}/>
        </div>
        <div class="flex items-center">
            <input type="text" placeholder="Search" class="outline-none flex items-center border border-black-600 rounded-l-lg px-4 py-2 " />
            <div class="w-11 h-10 flex items-center bg-blue-500 rounded-r-lg">
                <BsSearch class="h-5 w-6 ml-2 text-white"/>
            </div>
        </div>
        {/*<div class="flex items-center border border-black-600 rounded-full px-4 py-2 bg-gray-300 w-80" >
            <input type="text" placeholder="Search" class="outline-none placeholder-gray-400 bg-gray-300 flex-grow mr-2 border-gray-300"/>
            <div class="text-gray-400">
                <BsSearch class="h-6 w-6" />
            </div>
        </div>
*/}


        <div class='flex h-35'>
            <NavLink to='/feedbacks' activeClassName='active'>
                <MdOutlineFeedback id='icon1' className='icon' />
            </NavLink>
            <NavLink to='/notifications' activeClassName='active'>
                <BsFillBellFill id='icon2' className='icon' />
            </NavLink>
            <NavLink to='/profile' activeClassName='active'>
                <BsPersonCircle id='icon3' className='icon' />
            </NavLink>
      </div>
    </header>
  )
}

export default Header
