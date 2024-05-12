import React, { useState } from "react";
import Title from "../pagename/Title";
import { IoCameraOutline } from "react-icons/io5";
import userSix from '../../images/user/userImage-min.png';

const Profile = () => {
  const [firstName, setFirstName] = useState("Kaleb");
  const [lastName, setLastName] = useState("Tesfaye");
  const [email, setEmail] = useState("Kaleb.tes@example.com");
  const [phoneNumber, setPhoneNumber] = useState("+1234567890");
  const [address, setAddress] = useState("123 Main Street, City, Country");
  const [isEditing, setIsEditing] = useState(false);


  const handleEditToggle = () => {
    setIsEditing(!isEditing);
  };
  const handleSubmit = (e) => {
    e.preventDefault();
    setIsEditing(false);
  };

  return (
    <div className="h-96">
      <Title pageName="Profile" />

      <div className="overflow-hidden rounded-sm border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
        
        <div className="relative px-4 pb-6 text-center lg:pb-8 xl:pb-11.5">
          <div className="relative z-50 mx-auto mt-20 h-32 w-full max-w-32  backdrop-blur sm:h-44 sm:max-w-44 sm:p-3 overflow-hidden">
            <div className="relative drop-shadow-2">
              <img 
                src={userSix} 
                alt="profile" 
                className="w-32 h-32 object-cover object-center rounded-full border-4 border-white shadow-lg" />
              <label
                htmlFor="profile"
                className="absolute bottom-1right-1 flex cursor-pointer items-center justify-center rounded-full bg-primary text-white hover:bg-opacity-90 sm:bottom-2 sm:right-2"
              >
                <span className="h-6 w-6 rounded-full  bg-sky-800 overflow-hidden">
                <IoCameraOutline className="ml-1 mt-1"/>
                </span>
                <input
                  type="file"
                  name="profile"
                  id="profile"
                  className="sr-only"
                />
              </label>
            </div>
          </div>
          <div className="max-w-lg mx-auto bg-white drop-shadow-2xl rounded-md p-6">
            <h2 className="text-2xl font-semibold mb-4">Admin Profile</h2>
            <form onSubmit={handleSubmit}>
              <div className="mb-4">
                <label htmlFor="firstName" className="block font-semibold mb-1">
                  First Name
                </label>
                <input
                  type="text"
                  id="firstName"
                  name="firstName"
                  value={firstName}
                  onChange={(e) => setFirstName(e.target.value)}
                  disabled={!isEditing}
                  className="w-full h-10 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring focus:ring-blue-200 disabled:bg-gray-100 disabled:cursor-not-allowed"
                />
              </div>
              <div className="mb-4">
                <label htmlFor="lastName" className="block font-semibold mb-1">
                  Last Name
                </label>
                <input
                  type="text"
                  id="lastName"
                  name="lastName"
                  value={lastName}
                  onChange={(e) => setLastName(e.target.value)}
                  disabled={!isEditing}
                  className="w-full h-10 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring focus:ring-blue-200 disabled:bg-gray-100 disabled:cursor-not-allowed"
                />
              </div>
              <div className="mb-4">
                <label htmlFor="email" className="block font-semibold mb-1">
                  Email
                </label>
                <input
                  type="email"
                  id="email"
                  name="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  disabled={!isEditing}
                  className="w-full h-10 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring focus:ring-blue-200 disabled:bg-gray-100 disabled:cursor-not-allowed"
                />
              </div>
              <div className="mb-4">
                <label htmlFor="phoneNumber" className="block font-semibold mb-1">
                  Phone Number
                </label>
                <input
                  type="tel"
                  id="phoneNumber"
                  name="phoneNumber"
                  value={phoneNumber}
                  onChange={(e) => setPhoneNumber(e.target.value)}
                  disabled={!isEditing}
                  className="w-full h-10 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring focus:ring-blue-200 disabled:bg-gray-100 disabled:cursor-not-allowed"
                />
              </div>
              <div className="mb-4">
                <label htmlFor="address" className="block font-semibold mb-1">
                  Address
                </label>
                <textarea
                  id="address"
                  name="address"
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  disabled={!isEditing}
                  className="w-full h-32 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring focus:ring-blue-200 disabled:bg-gray-100 disabled:cursor-not-allowed"
                ></textarea>
              </div>
              <div className="flex justify-end">
                {!isEditing ? (
                  <button
                    type="button"
                    onClick={handleEditToggle}
                    className="bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600 focus:outline-none focus:bg-blue-600"
                  >
                    Edit
                  </button>
                ) : (
                  <button
                    type="submit"
                    className="bg-green-500 text-white px-4 py-2 rounded-md hover:bg-green-600 focus:outline-none focus:bg-green-600"
                  >
                    Save
                  </button>
                )}
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Profile;
