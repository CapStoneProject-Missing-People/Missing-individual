import React from 'react';
import { useRoutes } from 'react-router-dom';
import MainDashboard from './components/MainContent/Dashboard/MainDashboard';
import MainUserManagement from './components/MainContent/UserManagement/MainUserManagement';
import MainMissingPeople from './components/MainContent/MissingPeople/MainMissingPeople';
import MainLogManagement from './components/MainContent/LogManagement/MainLogManagement';
import MainFacialDescription from './components/MainContent/FacialAndDescription/MainFacialDescription';
import MainReports from './components/MainContent/Reports/MainReports';
import MainSetting from './components/MainContent/Setting/MainSetting';
import MainFeedback from './components/MainContent/Feedback/MainFeedback';
import MainNotifications from './components/MainContent/Notifications/MainNotifications';
import MainProfile from './components/MainContent/Profile/MainProfile';

function Routes () {
  let element = useRoutes([
    { path: '/dashboard', element: <MainDashboard /> },
    { path: '/user-management', element: <MainUserManagement /> },
    { path: '/missing-people', element: <MainMissingPeople /> },
    { path: '/log-management', element: <MainLogManagement /> },
    { path: '/facial-description', element: <MainFacialDescription /> },
    { path: '/reports', element: <MainReports /> },
    { path: '/setting', element: <MainSetting /> },
    { path: '/feedbacks', element: <MainFeedback /> },
    { path: '/notifications', element: <MainNotifications /> },
    { path: '/profile', element: <MainProfile /> },
  ]);


  return element;
};

export default Routes;
