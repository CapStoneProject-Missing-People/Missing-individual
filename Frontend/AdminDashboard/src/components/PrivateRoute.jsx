import React from 'react';
import { Navigate } from 'react-router-dom';
import Cookies from 'js-cookie';

const PrivateRoute = ({ children }) => {
  const token = Cookies.get('jwt');
  
  if (!token) {
    return <Navigate to="/" replace />;
  }

  return children;
};

export default PrivateRoute;
