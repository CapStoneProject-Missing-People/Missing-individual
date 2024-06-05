import React, { useState, useEffect } from 'react';
import { IoIosCloseCircle } from 'react-icons/io';
import axios from 'axios';

const PersonCard = ({ person }) => {
  const [images, setImages] = useState([]);
  const [isUploading, setIsUploading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    const fetchImages = async () => {
      try {
        const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
        const headers = {
          Authorization: `Bearer ${token}`,
        };

        const response = await axios.get(`http://localhost:4000/api/get-images-with-names`, { headers });
        console.log("the datas are: ",response.data)
        const initialImages = response.data.map(item => {
          const byteArray = new Uint8Array(item.imageBuffers[0].data);
          const blob = new Blob([byteArray], { type: 'image/jpg' });
          return URL.createObjectURL(blob);
        });
        setImages(initialImages);
      } catch (error) {
        console.error("Error fetching images:", error);
      }
    };

    fetchImages();
  }, [person._id]);

  const handleImageUpload = async (event) => {
    const files = Array.from(event.target.files);
    if (files.length === 0 || images.length >= 5) return;

    const formData = new FormData();
    formData.append('photos', files[0]);

    try {
      setIsUploading(true);
      const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
      const headers = {
        Authorization: `Bearer ${token}`,
      };

      const response = await axios.post(`http://localhost:4000/api/features/uploadPhotos/${person._id}`, formData, { headers });

      const imageBuffer = response.data.data;
      const byteArray = new Uint8Array(imageBuffer);
      const blob = new Blob([byteArray], { type: 'image/jpeg' });
      const newImage = URL.createObjectURL(blob);
      setImages(prevImages => [...prevImages, newImage]);
    } catch (error) {
      console.error("Error uploading images:", error);
    } finally {
      setIsUploading(false);
    }
  };

  const handleRemoveImage = (index) => {
    setImages(prevImages => prevImages.filter((_, i) => i !== index));
  };

  const handleSubmit = async () => {
    try {
      setIsSubmitting(true);
      const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
      const headers = {
        Authorization: `Bearer ${token}`,
      };

      const response = await axios.post(`http://localhost:4000/api/features/updateImages/${person._id}`, { images }, { headers });
      console.log("Images updated successfully:", response.data);
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
          <input type="file" className="hidden" onChange={handleImageUpload} disabled={isUploading || images.length >= 5} />
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
        {images.length < 5 && (
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
