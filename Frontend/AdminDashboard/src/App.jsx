import React from 'react';
import { Route, Routes } from 'react-router-dom';
import MainLayout from './components/layouts/MainLayout';
import MenuContextProvider from './context/MenuContext'; 
import MainDashboard from './components/page/Dashboard/MainDashboard'
import MainUserManagement from './components/page/UserManagement/MainUserManagement';
import MainMissingPeople from './components/page/MissingPeople/MainMissingPeople';
import Profile from './components/page/Profile';
import MainFeedback from './components/page/Feedback/MainFeedback';
import MainLogManagement from './components/page/LogManagement/MainLogManagement';

const App = () => {
  return (
    <MenuContextProvider>
      <MainLayout>
        <Routes>
          <Route path="/" element={<MainDashboard />} />
          <Route path="/dashboard" element={<MainDashboard />} />
          <Route path="/user-management" element={<MainUserManagement />} />
          <Route path="/missing-people" element={<MainMissingPeople />} />
          <Route path="/profiles" element={<Profile/>}/>
          <Route path="/feedbacks" element={<MainFeedback/>}/>
          <Route path="/log-management" element={<MainLogManagement/>}/> 

        </Routes>
      </MainLayout>
    </MenuContextProvider>
  );
};

export default App;
