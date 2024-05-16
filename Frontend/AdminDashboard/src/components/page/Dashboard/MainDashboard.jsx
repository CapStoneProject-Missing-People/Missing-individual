import React from 'react'
import CardDataStats from "./CardDataStats.jsx";
import Charts from './Charts';

function MainDashboard() {
  return (
    <main  className="h-96">
        <div className='font-semibold mb-4'>
            <h3>DASHBOARD</h3>
        </div>
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 md:gap-6 xl:grid-cols-4 2xl:gap-7.5">
          <CardDataStats title="Log management" address="/log-management" rate="0.43%" levelUp>
          </CardDataStats>
          <CardDataStats title="Feedback Collection" address="/feedbacks" rate="0.43%" levelUp>
          </CardDataStats>
          <CardDataStats title="Reporting Tools" address="reports" rate="0.43%" levelUp>
          </CardDataStats>
          <CardDataStats title="Alerts" address="/notifications" rate="0.43%" levelUp>
          </CardDataStats>
        </div>
        <div className="mt-4 grid grid-cols-12 gap-4 md:mt-6 md:gap-6 2xl:mt-7.5 2xl:gap-7.5">
          <Charts/>
        </div>
       
    </main>
  )
}

export default MainDashboard