import { useEffect, useState, useContext } from "react";
import { useRef } from "react";
import { motion } from "framer-motion";
import { IoIosArrowBack } from "react-icons/io";
import { SlSettings } from "react-icons/sl";
import { RiBuilding3Line } from "react-icons/ri";
import { useMediaQuery } from "react-responsive";
import { NavLink, useLocation, useRoutes } from "react-router-dom";
import Submenu from "./Submenu";
import { MenuContext } from "../../../context/MenuContext";
import { MdOutlineFeedback, MdDashboard, MdOutlineManageAccounts } from "react-icons/md";
import { FaArrowsDownToPeople } from "react-icons/fa6";
import { SiMicrosoftonenote } from "react-icons/si";
import { TbTextRecognition } from "react-icons/tb";
import { FaUser } from "react-icons/fa";
import Logo from "./newlogo.png"
import axios from 'axios';
import Cookies from 'js-cookie';

const subsubMenuList = [
  {
    name: "Storage",
    icon: RiBuilding3Line,
    menus: ["storage1", "storage2", "storage3", "storage4"],
  },
];

const subMenusList = [
  {
    name: "Features",
    icon: TbTextRecognition,
    menus: ["Facial recognition", "Description match"],
  },
 
];

const Sidebar = () => {
  let isTabletMid = useMediaQuery({ query: "(max-width: 768px)" });
  const { isOpen, toggleMenu } = useContext(MenuContext);
  const [open, setOpen] = useState(isTabletMid ? false : true);
  const sidebarRef = useRef();
  const { pathname } = useLocation();
  const [loggedInUserRole, setLoggedInUserRole] = useState(null);

  useEffect(() => {
    const fetchLoggedInUserRole = async () => {
      try {
        const token = Cookies.get('jwt');
        const response = await axios.get('http://localhost:4000/api/profile/current', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setLoggedInUserRole(response.data.role);
      } catch (error) {
        console.error('Error fetching logged-in user data:', error);
      }
    };
    fetchLoggedInUserRole();
  }, []);

  useEffect(() => {
    if (isTabletMid) {
      setOpen(false);
    } else {
      setOpen(true);
    }
  }, [isTabletMid]);

  useEffect(() => {
    isTabletMid && setOpen(false);
  }, [pathname]);

  const Nav_animation = isTabletMid
    ? {
        open: {
          x: 0,
          width: "16rem",
          transition: {
            damping: 40,
          },
        },
        closed: {
          x: -250,
          width: 0,
          transition: {
            damping: 40,
            delay: 0.15,
          },
        },
      }
    : {
        open: {
          width: "16rem",
          transition: {
            damping: 40,
          },
        },
        closed: {
          width: "4rem",
          transition: {
            damping: 40,
          },
        },
      };
      const [subMenuOpen, setSubMenuOpen] = useState(false);

      const toggleSubMenu = () => {
        setSubMenuOpen(!subMenuOpen);
      };
    
  return (
    <div>
      <div
        onClick={toggleMenu}
        className={`md:hidden fixed inset-0 max-h-screen z-[998] bg-black/50 ${
          isOpen ? "block" : "hidden"
        } `}
      ></div>
      <motion.div
        ref={sidebarRef}
        variants={Nav_animation}
        initial={{ x: isTabletMid ? -250 : 0 }}
        animate={isOpen ? "open" : "closed"}
        className=" bg-gray-800 text-gray shadow-xl z-[999] max-w-[16rem]  w-[16rem] 
          overflow-hidden md:relative fixed
       h-screen "
      >
        <div className="flex items-center gap-2.5 font-medium border-b py-3 border-slate-300  mx-3">
          <NavLink to={"/dashboard"}>
            <img
            src={Logo}
            width={45}
            alt=""
           className="h-10 w-10 rounded-full"
          />
          </NavLink>
          
          <NavLink to={"/dashboard"}>
            <span className="text-xl text-gray-200 whitespace-pre">
            FindMe
          </span>
          </NavLink>
          
        </div>

        <div className="flex flex-col  ">
          <ul className="whitespace-pre px-2.5 text-[0.9rem] py-5 flex flex-col gap-1  font-medium overflow-x-hidden scrollbar-thin scrollbar-track-white scrollbar-thumb-slate-100   md:h-[68%] h-[70%]">
            <li>
              <NavLink to={"/dashboard"} className={({ isActive }) =>
                  `link text-gray-200 hover:bg-sky-700 ${isActive ? "bg-sky-600" : ""}`
                }>
                <MdDashboard
                  size={23}
                  className="min-w-max text-gray-200"
                />
                Dashboard
              </NavLink>
            </li>
            <li>
              <NavLink to={"/user-management"} className={({ isActive }) =>
                  `link text-gray-200 hover:bg-sky-700 ${isActive ? "bg-sky-600" : ""}`
                }>
                <FaUser size={23} className="min-w-max text-gray-200" />
                User Management
              </NavLink>
            </li>
            {loggedInUserRole === 'superAdmin' && (
              <li>
                <NavLink to={"/admin-management"} className={({ isActive }) =>
                    `link text-gray-200 hover:bg-sky-700 ${isActive ? "bg-sky-600" : ""}`
                  }>
                  <MdOutlineManageAccounts size={23} className="min-w-max text-gray-200" />
                  Admin Management
                </NavLink>
              </li>
            )}
            <li>
              <NavLink to={"/missing-people"} className={({ isActive }) =>
                  `link text-gray-200 hover:bg-sky-700 ${isActive ? "bg-sky-600" : ""}`
                }>
                <FaArrowsDownToPeople
                  size={23}
                  className="min-w-max text-gray-200"
                />
                Missing people
              </NavLink>
            </li>
            <li>
              <NavLink to={"/log-management"} className={({ isActive }) =>
                  `link text-gray-200 hover:bg-sky-700 ${isActive ? "bg-sky-600" : ""}`
                }>
                <SiMicrosoftonenote
                  size={23}
                  className="min-w-max text-gray-200"
                />
                Log Management
              </NavLink>
            </li>
            <li>
              <NavLink to={"/feedbacks"} className={({ isActive }) =>
                  `link text-gray-200 hover:bg-sky-700 ${isActive ? "bg-sky-600" : ""}`
                }>
                <MdOutlineFeedback
                  size={23}
                  className="min-w-max text-gray-200"
                />
                Feedbacks
              </NavLink>
            </li>
            

            {(isOpen || isTabletMid) && (
              <div className="border-y py-5 border-slate-300 ">
                
                {subMenusList?.map((menu) => (
                  <div
                    key={menu.name}
                    className="flex flex-col gap-1 text-gray-400 "
                  >
                    <Submenu data={menu} isOpen={subMenuOpen} toggleSubMenu={toggleSubMenu}/>
                    
                  </div>
                ))}
              </div>
            )}
            
          </ul>
          
        </div>
        <motion.div
          onClick={() => {
            // setOpen(!open);
            toggleMenu(!isOpen);
          }}
          animate={
            open
              ? {
                  x: 0,
                  y: 0,
                  rotate: 0,
                }
              : {
                  x: -10,
                  y: -200,
                  rotate: 180,
                }
          }
          transition={{ duration: 0 }}
          className="absolute text-gray-300 w-fit h-fit md:block z-50 hidden right-2 bottom-3 cursor-pointer"
        >
          <IoIosArrowBack size={25} />
        </motion.div>
      </motion.div>
    
    </div>
  );
};

export default Sidebar;