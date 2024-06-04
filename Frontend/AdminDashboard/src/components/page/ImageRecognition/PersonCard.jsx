import React, { useState } from 'react';
import { IoIosCloseCircle } from 'react-icons/io';
import axios from 'axios';

const PersonCard = ({ person }) => {
  const [images, setImages] = useState([]);

  const handleImageUpload = async (event) => {
    const files = Array.from(event.target.files);
    const formData = new FormData();
    files.forEach(file => {
      formData.append('photos', file);
    });

    try {
      const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
      const headers = {
        Authorization: `Bearer ${token}`,
      };

      const response = await axios.post(`http://localhost:4000/api/features/uploadPhotos/${person._id}`, formData, { headers });
      const newImages = response.data.map(image => image.url);
      setImages(prevImages => [...prevImages, ...newImages]);
    } catch (error) {
      console.error("Error uploading images:", error);
    }
  };

  const handleRemoveImage = async (index) => {
    const imageToRemove = images[index];
    try {
      const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
      const headers = {
        Authorization: `Bearer ${token}`,
      };

      await axios.delete(`http://localhost:4000/api/features/removePhoto/${person._id}`, { data: { url: imageToRemove }, headers });
      setImages(prevImages => prevImages.filter((_, i) => i !== index));
    } catch (error) {
      console.error("Error removing image:", error);
    }
  };

  return (
    <div className="p-4 border rounded-lg shadow-lg">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-bold">{person.firstName}</h2>
        <label className="cursor-pointer bg-blue-500 text-white px-4 py-2 rounded-lg">
          Upload
          <input type="file" multiple className="hidden" onChange={handleImageUpload} />
        </label>
      </div>
      <div className="mt-4 grid grid-cols-3 gap-2">
        {images.map((image, index) => (
          <div key={index} className="relative">
            <img src={image} alt="Uploaded" className="w-full h-32 object-cover" />
            <IoIosCloseCircle
              className="absolute top-0 right-0 text-red-600 cursor-pointer"
              onClick={() => handleRemoveImage(index)}
            />
          </div>
        ))}
      </div>
    </div>
  );
};

export default PersonCard;
