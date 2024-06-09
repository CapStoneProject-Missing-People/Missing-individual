import React, { useState } from 'react';
import { Route, Routes, Navigate } from 'react-router-dom';
import MainLayout from './components/layouts/MainLayout';
import MenuContextProvider from './context/MenuContext';
import MainDashboard from './components/page/Dashboard/MainDashboard';
import MainUserManagement from './components/page/UserManagement/MainUserManagement';
import MainAdminManagement from './components/page/AdminManagement/MainAdminManagement';
import MainMissingPeople from './components/page/MissingPeople/MainMissingPeople';
import Profile from './components/page/Profile';
import MainFeedback from './components/page/Feedback/MainFeedback';
import MainLogManagement from './components/page/LogManagement/MainLogManagement';
import MainImageRecognition from './components/page/ImageRecognition/MainImageRecognition';
import Login from './components/page/Login';
import MainReportPage from './components/page/ReportPage/MainReportPage';
import PrivateRoute from './components/PrivateRoute';

const App = () => {
  const [user, setUser] = useState(null);

  return (
    <MenuContextProvider>
      <Routes>
        <Route path="/" element={<Login setUser={setUser}/>} /> {/* Render Login page by default */}
        <Route
          path="/dashboard"
          element={
            <PrivateRoute>
              <MainLayout>
                <MainDashboard />
              </MainLayout>
            </PrivateRoute>
          }
        />
        <Route
          path="/user-management"
          element={
            <PrivateRoute>
              <MainLayout>
                <MainUserManagement />
              </MainLayout>
            </PrivateRoute>
          }
        />
        <Route
          path="/admin-management"
          element={
            <PrivateRoute>
              <MainLayout>
                <MainAdminManagement />
              </MainLayout>
            </PrivateRoute>
          }
        />
        <Route
          path="/missing-people"
          element={
            <PrivateRoute>
              <MainLayout>
                <MainMissingPeople />
              </MainLayout>
            </PrivateRoute>
          }
        />
        <Route
          path="/profiles"
          element={
            <PrivateRoute>
              <MainLayout>
                <Profile />
              </MainLayout>
            </PrivateRoute>
          }
        />
        <Route
          path="/feedbacks"
          element={
            <PrivateRoute>
              <MainLayout>
                <MainFeedback />
              </MainLayout>
            </PrivateRoute>
          }
        />
        <Route
          path="/log-management"
          element={
            <PrivateRoute>
              <MainLayout>
                <MainLogManagement />
              </MainLayout>
            </PrivateRoute>
          }
        />
        <Route
          path="/img-recognitions"
          element={
            <PrivateRoute>
              <MainLayout>
                <MainImageRecognition />
              </MainLayout>
            </PrivateRoute>
          }
        />
        {/* Redirect to Login page for any other route */}
        <Route path="*" element={<Navigate to="/" replace />} /> 
      </Routes>
    </MenuContextProvider>
  );
};

export default App;
