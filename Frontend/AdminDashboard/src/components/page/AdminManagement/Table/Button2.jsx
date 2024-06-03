import React from 'react';

function Button2({ content, onClick, active, disabled }) {
  return (
    <button
      className={`flex flex-col cursor-pointer items-center justify-center w-9 h-9 shadow-[0_4px_10px_rgba(0,0,0,0.03)] text-sm font-normal transition-colors rounded-lg ${
        active ? "new-color text-white" : "text-slate-900"
      } ${
        !disabled ? "bg-white hover:bg-gray-500 hover:text-white" : "text-slate-600 bg-white cursor-not-allowed"
      }`}
      onClick={onClick}
      disabled={disabled}
    >
      {content}
    </button>
  );
}

export default Button2;
