import React from 'react';
import { Route, Routes, Navigate } from 'react-router-dom';
import MainLayout from './components/layouts/MainLayout';
import MenuContextProvider from './context/MenuContext';
import MainDashboard from './components/page/Dashboard/MainDashboard';
import MainUserManagement from './components/page/UserManagement/MainUserManagement';
import MainMissingPeople from './components/page/MissingPeople/MainMissingPeople';
import Profile from './components/page/Profile';
import MainFeedback from './components/page/Feedback/MainFeedback';
import MainLogManagement from './components/page/LogManagement/MainLogManagement';
import Login from './components/page/Login'; // Import Login component

const App = () => {
  return (
    <MenuContextProvider>
      <Routes>
        <Route path="/" element={<Login />} /> {/* Render Login page by default */}
        <Route
          path="/dashboard"
          element={
            <MainLayout>
              <MainDashboard />
            </MainLayout>
          }
        />
        <Route
          path="/user-management"
          element={
            <MainLayout>
              <MainUserManagement />
            </MainLayout>
          }
        />
        <Route
          path="/missing-people"
          element={
            <MainLayout>
              <MainMissingPeople />
            </MainLayout>
          }
        />
        <Route
          path="/profiles"
          element={
            <MainLayout>
              <Profile />
            </MainLayout>
          }
        />
        <Route
          path="/feedbacks"
          element={
            <MainLayout>
              <MainFeedback />
            </MainLayout>
          }
        />
        <Route
          path="/log-management"
          element={
            <MainLayout>
              <MainLogManagement />
            </MainLayout>
          }
        />
        <Route path="*" element={<Navigate to="/" replace />} /> {/* Redirect to Login page for any other route */}
      </Routes>
    </MenuContextProvider>
  );
};

export default App;
