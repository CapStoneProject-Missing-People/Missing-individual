import React from 'react';

const UserDetail = ({ user }) => {
  return (
    <div>
      <h2 className="text-lg font-bold mb-2">User Details</h2>
      <p>Name: {user.name}</p>
      <p>Email: {user.email}</p>
    </div>
  );
}

export default UserDetail;
