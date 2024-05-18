import { useEffect, useState } from 'react';
import axios from 'axios';

const Log = () => {
  const [logs, setLogs] = useState([]); 
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchLogs = async () => {
      try {
        const response = await axios.get('http://localhost:3000/api/get-action-logs');
        console.log(response)
        setLogs(response.data);
        setLoading(false);
      } catch (error) {
        console.error('Error fetching logs:', error);
        setError('Error fetching logs. Please try again later.');
        setLoading(false);
      }
    };

    fetchLogs();
  }, []);

  if (error) {
    return (
      <div className="container mx-auto px-4 text-center mt-8">
        <p>{error}</p>
        <p className='font-Montserrat'>API endpoint is not available. Please check the server status.</p>
      </div>
    );
  }

  if (loading) {
    return <div className="container mx-auto px-4 text-center mt-8">Loading...</div>;
  }

  return (
    <div className="container mx-auto px-4">
      <div className="overflow-x-auto">
        <table className="min-w-full border-collapse border border-gray-200">
          <thead>
            <tr className="bg-gray-100">
              <th className="py-2 px-4 text-left">Timestamp</th>
              <th className="py-2 px-4 text-left">Action</th>
              <th className="py-2 px-4 text-left">User ID</th>
              <th className="py-2 px-4 text-left">User Agent</th>
              <th className="py-2 px-4 text-left">Method</th>
              <th className="py-2 px-4 text-left">IP</th>
              <th className="py-2 px-4 text-left">Status</th>
              <th className="py-2 px-4 text-left">Error</th>
              <th className="py-2 px-4 text-left">Log Level</th>
            </tr>
          </thead>
          <tbody>
            {logs.map(log => (
              <tr key={log._id} className="border-b border-gray-200">
                <td className="py-2 px-4">{new Date(log.timestamp).toLocaleString()}</td>
                <td className="py-2 px-4">{log.action}</td>
                <td className="py-2 px-4">{log.user_id}</td>
                <td className="py-2 px-4">{log.user_agent}</td>
                <td className="py-2 px-4">{log.method}</td>
                <td className="py-2 px-4">{log.ip}</td>
                <td className="py-2 px-4">{log.status}</td>
                <td className="py-2 px-4">{log.error || '-'}</td>
                <td className="py-2 px-4">{log.logLevel}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Log;
