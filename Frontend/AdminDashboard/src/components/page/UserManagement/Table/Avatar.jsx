// Avatar.js
import React from 'react';

const Avatar = ({ src, name }) => {
  return src ? (
    <img src={src} alt={`${name}'s Avatar`} className="w-8 h-8 rounded-full" />
  ) : (
    <div className="w-8 h-8 bg-gray-500 text-white rounded-full flex items-center justify-center">
      {name.charAt(0)}
    </div>
  );
};

export default Avatar;
