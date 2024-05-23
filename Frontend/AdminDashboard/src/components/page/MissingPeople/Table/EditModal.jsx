import React, { useState, useEffect } from 'react';
import Modal from 'react-modal';
import { IoIosCloseCircle } from 'react-icons/io';

const EditModal = ({ isOpen, onClose, user }) => {
  const [formData, setFormData] = useState({
    firstName: '',
    middleName: '',
    lastName: '',
    gender: '',
    age: '',
    skin_color: '',
    description: '',
    body_size: '',
    medicalInformation: '',
    circumstanceOfDisappearance: '',
  });

  useEffect(() => {
    if (user) {
      setFormData({
        firstName: user.name.firstName || '',
        middleName: user.name.middleName || '',
        lastName: user.name.lastName || '',
        gender: user.gender || '',
        age: user.age || '',
        skin_color: user.skin_color || '',
        description: user.description || '',
        body_size: user.body_size || '',
        medicalInformation: user.medicalInformation || '',
        circumstanceOfDisappearance: user.circumstanceOfDisappearance || '',
      });
    }
  }, [user]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value,
    });
  };

  const handleSubmit = () => {
    console.log(formData);
    onClose();
  };

  if (!isOpen || !user) {
    return null;
  }

  return (
    <Modal isOpen={isOpen} onRequestClose={onClose}>
      <div className="fixed inset-0 flex items-center justify-center z-50">
        <div
          className="absolute inset-0 bg-black opacity-50"
          onClick={onClose}
        ></div>
        <div className="relative bg-white px-5 py-3 w-2/5 rounded-lg shadow-lg">
          <button
            className="absolute top-2 right-2 text-gray-500 hover:text-red-600"
            onClick={onClose}
          >
            <IoIosCloseCircle className="h-6 w-6 ml-auto" />
          </button>
          <div className="mb-4">
            <h2 className="text-xl font-semibold mb-4">Edit Missing Person</h2>
            <form onSubmit={handleSubmit}>
              <div className="flex flex-wrap -mx-2">
                <div className="w-full lg:w-1/2 px-2">
                  <div className="mb-4">
                    <label className="block text-sm font-medium text-gray-700">
                      First Name
                    </label>
                    <input
                      type="text"
                      id="firstName"
                      name="firstName"
                      value={formData.firstName}
                      onChange={handleInputChange}
                      className="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full"
                    />
                  </div>
                  <div className="mb-4">
                    <label className="block text-sm font-medium text-gray-700">
                      Middle Name
                    </label>
                    <input
                      type="text"
                      id="middleName"
                      name="middleName"
                      value={formData.middleName}
                      onChange={handleInputChange}
                      className="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full"
                    />
                  </div>
                  <div className="mb-4">
                    <label className="block text-sm font-medium text-gray-700">
                      Last Name
                    </label>
                    <input
                      type="text"
                      id="lastName"
                      name="lastName"
                      value={formData.lastName}
                      onChange={handleInputChange}
                      className="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full"
                    />
                  </div>
                  <div className="mb-4">
                    <label className="block text-sm font-medium text-gray-700">
                      Gender
                    </label>
                    <input
                      type="text"
                      id="gender"
                      name="gender"
                      value={formData.gender}
                      onChange={handleInputChange}
                      className="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full"
                    />
                  </div>
                  <div className="mb-4">
                    <label className="block text-sm font-medium text-gray-700">
                      Age
                    </label>
                    <input
                      type="number"
                      id="age"
                      name="age"
                      value={formData.age}
                      onChange={handleInputChange}
                      className="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full"
                    />
                  </div>
                  <div className="mb-4">
                    <label className="block text-sm font-medium text-gray-700">
                      Skin Color
                    </label>
                    <input
                      type="text"
                      id="skin_color"
                      name="skin_color"
                      value={formData.skin_color}
                      onChange={handleInputChange}
                      className="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full"
                    />
                  </div>
                </div>
                <div className="w-full lg:w-1/2 px-2">
                  <div className="mb-4">
                    <label className="block text-sm font-medium text-gray-700">
                      Description
                    </label>
                    <textarea
                      id="description"
                      name="description"
                      value={formData.description}
                      onChange={handleInputChange}
                      className="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full h-28 resize-none"
                    ></textarea>
                  </div>
                  <div className="mb-4">
                    <label className="block text-sm font-medium text-gray-700">
                      Body Size
                    </label>
                    <input
                      type="text"
                      id="body_size"
                      name="body_size"
                      value={formData.body_size}
                      onChange={handleInputChange}
                      className="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full"
                    />
                  </div>
                  <div className="mb-4">
                    <label className="block text-sm font-medium text-gray-700">
                      Medical Information
                    </label>
                    <textarea
                      id="medicalInformation"
                      name="medicalInformation"
                      value={formData.medicalInformation}
                      onChange={handleInputChange}
                      className="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full h-28 resize-none"
                    ></textarea>
                  </div>
                  <div className="mb-4">
                    <label className="block text-sm font-medium text-gray-700">
                      Circumstance of Disappearance
                    </label>
                    <textarea
                      id="circumstanceOfDisappearance"
                      name="circumstanceOfDisappearance"
                      value={formData.circumstanceOfDisappearance}
                      onChange={handleInputChange}
                      className="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full h-28 resize-none"
                    ></textarea>
                  </div>
                </div>
              </div>
              <div className="flex justify-center">
                <button
                  type="button"
                  onClick={handleSubmit}
                  className="px-4 py-2 mr-5 w-36 font-inter bg-blue-500 text-white rounded-md hover:bg-blue-600"
                >
                  Save
                </button>
                <button
                  type="button"
                  onClick={onClose}
                  className="ml-2 px-4 py-2 w-36 font-inter bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </Modal>
  );
};

export default EditModal;
