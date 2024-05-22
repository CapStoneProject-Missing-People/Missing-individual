import React from 'react';

const Modal = ({ show, onClose, onConfirm }) => {
  if (!show) {
    return null;
  }

  return (
    <div className="fixed inset-0 bg-gray-500 bg-opacity-75 flex justify-center items-center z-50" 
        onClick={onClose}
    >
      <div className="bg-white rounded-lg p-6 space-y-4 w-96">
        <h2 className="text-lg font-semibold">Are you sure?</h2>
        <p>Do you really want to delete this user? This action cannot be undone.</p>
        <div className="flex justify-end gap-4">
          <button
            onClick={onClose}
            className="bg-gray-300 text-black px-4 py-2 rounded-lg"
          >
            No
          </button>
          <button
            onClick={onConfirm}
            className="bg-red-600 text-white px-4 py-2 rounded-lg"
          >
            Yes
          </button>
        </div>
      </div>
    </div>
  );
};

export default Modal;
