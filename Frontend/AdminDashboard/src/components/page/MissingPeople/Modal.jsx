import React, { useState } from 'react';
import Modal from 'react-modal';
import { IoIosCloseCircle } from "react-icons/io";

const EditModal = ({ isOpen, onClose, user }) => {

    const [formData, setFormData] = useState({
      name: user?.name||'',
      email: user?.email||'',
      age: user?.age||'',

    });
  
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
      <Modal isOpen={isOpen} onRequestClose={onClose} >
        <div class="fixed inset-0 flex items-center justify-center z-50">
            <div class="absolute inset-0 bg-black opacity-50" onClick={onClose}></div>
            <div class="relative bg-white px-5 py-3 w-96 rounded-lg shadow-lg">
                <button
                class="absolute top-2 right-2 text-gray-500 hover:text-red-600"
                onClick={onClose}
                >
                <IoIosCloseCircle class="h-6 w-6 ml-auto"/>
                </button>
                <div class="mb-4">
                    <h2 className=" text-xl font-semibold mb-4">Edit User</h2>
                    <form onSubmit={handleSubmit}>
                        <div className="mb-4">
                        <label  className="block text-sm font-interfont-medium text-gray-700">
                            Name
                        </label>
                        <input
                            type="text"
                            id="name"
                            name="name"
                            value={formData.name}
                            onChange={handleInputChange}
                            class="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full"
                            />
                        </div>
                        <div className="mb-4">
                            <label className="outline-none block text-sm font-inter font-medium text-gray-700">
                                Email
                            </label>
                            <input
                                type="email"
                                id="email"
                                name="email"
                                value={formData.email}
                                onChange={handleInputChange}
                                className="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full"
                            />
                        </div>
                        <div className="mb-4">
                            <label  className="block text-sm font-medium text-gray-700">
                                Description
                            </label>
                            <textarea
                                type="number"
                                id="age"
                                name="age"
                                value={formData.age}
                                onChange={handleInputChange}
                                className="mt-1 p-2 border font-inter text-black border-gray-300 rounded-md w-full h-28 resize-none"
                            ></textarea>
                        </div>

                       
                        <div class="flex justify-center">
                            <button
                                type="button"
                                onClick={handleSubmit}
                                class="px-4 py-2 mr-5 w-36 font-inter bg-blue-500 text-white rounded-md hover:bg-blue-600"
                            >
                                Save
                            </button>
                            <button
                                type="button"
                                onClick={onClose}
                                class="ml-2 px-4 py-2 w-36 font-inter bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400"
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
