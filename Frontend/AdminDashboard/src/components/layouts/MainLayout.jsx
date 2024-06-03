import React, { useContext } from "react";
import { MenuContext } from "../../context/MenuContext";
import Navbar from "./navbar/Navbar";
import Sidebar from "./sidebar/Sidebar";

const MainLayout = ({ children }) => {
  const { toggleMenu } = useContext(MenuContext);
  return (
    <div className="flex min-h-screen">
      <Sidebar className="fixed left-0 top-0 h-full" />
      <div className="flex flex-col w-full">
        <Navbar toggleMenu={toggleMenu} className="fixed top-0 left-0 w-full" />
        <main className="flex-grow overflow-y-auto">
          <div className="max-w-screen-2xl mx-auto p-4 md:p-6 2xl:p-10 relative">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
};

export default MainLayout;
