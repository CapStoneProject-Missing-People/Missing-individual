import React, { useState, useEffect } from "react";
import { IoIosCloseCircle } from "react-icons/io";

function Modal({ isOpen, onClose, person }) {
  const [editedPerson, setEditedPerson] = useState({});

  useEffect(() => {
    if (person) {
      setEditedPerson(person);
    }
  }, [person]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setEditedPerson({
      ...editedPerson,
      [name]: value,
    });
  };

  const handleSave = () => {
    //send editedPerson data to backend
    console.log("Saving edited person:", editedPerson);
    onClose();
  };

  return (
    <>
      {isOpen && (
        <div class="fixed inset-0 flex items-center justify-center z-50">
          <div class="absolute inset-0 bg-black opacity-50" onClick={onClose}></div>
          <div class="relative bg-white w-80 rounded-lg shadow-lg">
            <button
              class="absolute top-2 right-2 text-gray-500 hover:text-red-600"
              onClick={onClose}
            >
              <IoIosCloseCircle class="h-6 w-6 ml-auto"/>
            </button>
            <div class="p-6">
              <h2 class="text-xl font-bold font-inter text-black mb-4">Edit Person</h2>
              <form>
                <div class="mb-4">
                  <label class="block text-sm  font-interfont-medium text-gray-700">
                    Name
                  </label>
                  <input
                    type="text"
                    name="name"
                    value={editedPerson.name || ""}
                    onChange={handleChange}
                    class="mt-1 p-2 outline-none border font-inter border-gray-300 text-black rounded-md w-full"
                  />
                </div>
                <div class="mb-4">
                  <label class="outline-none block text-sm font-inter font-medium text-gray-700">
                    Description
                  </label>
                  <textarea
                    name="description"
                    value={editedPerson.description || ""}
                    onChange={handleChange}
                    class="mt-1 p-2 border font-inter text-black border-gray-300 rounded-md w-full h-24 resize-none"
                  ></textarea>
                </div>
                <div class="mb-4">
                  <label class="block text-sm font-inter font-medium text-gray-700">
                    Location
                  </label>
                  <input
                    type="text"
                    name="location"
                    value={editedPerson.location || ""}
                    onChange={handleChange}
                    class="mt-1 p-2 outline-none text-black font-inter border border-gray-300 rounded-md w-full"
                  />
                </div>
                <div class="flex justify-center">
                  <button
                    type="button"
                    onClick={handleSave}
                    class="px-4 py-2 mr-5 w-28 font-inter bg-blue-500 text-white rounded-md hover:bg-blue-600"
                  >
                    Save
                  </button>
                  <button
                    type="button"
                    onClick={onClose}
                    class="ml-2 px-4 py-2 w-28 font-inter bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

export default Modal;
