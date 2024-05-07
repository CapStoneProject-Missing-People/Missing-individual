import React from 'react'
import Cards from "./Cards";
import Charts from './Charts';
import data from "../../data.js";

function MainDashboard() {
  return (
    <main className='main-container'>
        <div className='main-title'>
            <h3>DASHBOARD</h3>
        </div>
        <Cards/>
        <Charts data={data}/>
    </main>
  )
}

export default MainDashboard