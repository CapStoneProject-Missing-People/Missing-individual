import React, { useState } from 'react';
import { IoIosCloseCircle } from 'react-icons/io';
import axios from 'axios';

const PersonCard = ({ person }) => {
  const [images, setImages] = useState(person.images);
  const [removedImages, setRemovedImages] = useState([]);
  const [newImages, setNewImages] = useState([]);
  const [isUploading, setIsUploading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleImageUpload = (event) => {
    const files = Array.from(event.target.files);
    if (files.length === 0 || images.length + newImages.length >= 5) return;

    const newImage = URL.createObjectURL(files[0]);
    setNewImages(prevNewImages => [...prevNewImages, { file: files[0], url: newImage }]);
  };

  const handleRemoveImage = (index, isNew) => {
    if (isNew) {
      setNewImages(prevNewImages => prevNewImages.filter((_, i) => i !== index));
    } else {
      const removedImage = images[index];
      setRemovedImages(prevRemovedImages => [...prevRemovedImages, removedImage.id]);
      setImages(prevImages => prevImages.filter((_, i) => i !== index));
    }
  };

  const handleSubmit = async () => {
    try {
      setIsSubmitting(true);
      const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
      const headers = {
        Authorization: `Bearer ${token}`,
      };

      const formData = new FormData();
      formData.append('missingId', person._id);

      newImages.forEach(newImage => {
        formData.append('images', newImage.file);
      });

      const response = await axios.put(`http://localhost:4000/api/update-image/${person._id}`, formData, {
        headers: {
          ...headers,
          'Content-Type': 'multipart/form-data',
        },
      });

      console.log("Images updated successfully", response.data);
    } catch (error) {
      console.error("Error submitting images:", error);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="p-4 border rounded-lg shadow-lg">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-bold">{person.firstName}</h2>
        <label className={`cursor-pointer bg-blue-500 text-white px-4 py-2 rounded-lg ${isUploading ? 'opacity-50 cursor-not-allowed' : ''}`}>
          Upload
          <input type="file" className="hidden" onChange={handleImageUpload} disabled={isUploading || images.length + newImages.length >= 5} />
        </label>
      </div>
      <div className="mt-4 grid grid-cols-3 gap-2">
        {images.map((image, index) => (
          <div key={index} className="relative">
            <img src={image.url} alt="Uploaded" className="w-full h-32 object-cover" />
            <IoIosCloseCircle
              className="absolute top-0 right-0 text-red-600 cursor-pointer"
              onClick={() => handleRemoveImage(index, false)}
            />
          </div>
        ))}
        {newImages.map((image, index) => (
          <div key={index + images.length} className="relative">
            <img src={image.url} alt="New Upload" className="w-full h-32 object-cover" />
            <IoIosCloseCircle
              className="absolute top-0 right-0 text-red-600 cursor-pointer"
              onClick={() => handleRemoveImage(index, true)}
            />
          </div>
        ))}
        {images.length + newImages.length === 0 && (
          <div className="w-full h-32 flex items-center justify-center border-2 border-dashed border-gray-300">
            <span className="text-gray-500">Empty</span>
          </div>
        )}
      </div>
      <button 
        className={`mt-4 bg-green-500 text-white px-4 py-2 rounded-lg ${isSubmitting ? 'opacity-50 cursor-not-allowed' : ''}`} 
        onClick={handleSubmit} 
        disabled={isSubmitting}
      >
        Submit
      </button>
    </div>
  );
};

export default PersonCard;
