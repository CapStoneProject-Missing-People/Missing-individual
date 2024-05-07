import React from 'react';
import { ResponsiveContainer, BarChart, CartesianGrid, XAxis, YAxis, Tooltip, Legend, LineChart, Line, Bar } from 'recharts';

function Charts ({data}) {
  return (
    <div className='charts'>
        <ResponsiveContainer width="100%" height="100%">
            <BarChart
                width={500}
                height={320}
                data={data}
                margin={{
                    top: 5,
                    right: 30,
                    left: 25,
                    bottom: 5,
                }}
            >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Bar dataKey="pv" fill="#8884d8" />
                <Bar dataKey="uv" fill="#82ca9d" />
            </BarChart>
        </ResponsiveContainer>

        <ResponsiveContainer width="100%" height="100%">
            <LineChart
                width={500}
                height={320}
                data={data}
                margin={{
                    top: 5,
                    right: 30,
                    left: 25,
                    bottom: 5,
                }}
            >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="pv" stroke="#8884d8" activeDot={{ r: 8 }} />
                <Line type="monotone" dataKey="uv" stroke="#82ca9d" />
            </LineChart>
        </ResponsiveContainer>

    </div>
  );
};

export default Charts;
