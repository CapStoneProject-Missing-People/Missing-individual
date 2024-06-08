import axios from 'axios';
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { IoEyeOutline, IoEyeOffOutline } from 'react-icons/io5';

const Login = ({ setUser }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordVisible, setPasswordVisible] = useState(false); // State for password visibility
  const [errors, setErrors] = useState({ email: '', password: '' });
  const [loginError, setLoginError] = useState(''); // State for generic login error
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Reset errors
    setErrors({ email: '', password: '' });
    setLoginError(''); // Reset generic login error

    try {
      const res = await axios.post('http://localhost:4000/api/users/adminLogin', {
        email,
        password
      }, {
        headers: {
          'Content-Type': 'application/json'
        }
      });

      const data = res.data;

      if (data.errors) {
        setErrors(data.errors);
      }

      if (data.user) {
        document.cookie = `jwt=${data.token}; path=/`; // Store JWT in the cookie
        setUser(data.user); // Set the user data in state or context
        navigate('/dashboard'); // Redirect to the home page or dashboard
      }
    } catch (err) {
      console.error('Error during login:', err);
      setLoginError('wrong email or password. Please try again.'); // Set generic login error
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100">
      <form
        className="bg-white p-8 rounded shadow-md w-full max-w-sm"
        onSubmit={handleSubmit}
      >
        <h2 className="text-2xl font-bold mb-6">Log in</h2>
        {loginError && (
          <div className="text-red-500 text-sm mb-4">{loginError}</div>
        )}
        <div className="mb-4">
          <label htmlFor="email" className="block text-gray-700 mb-2">
            Email
          </label>
          <input
            type="text"
            name="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="w-full px-3 py-2 border border-gray-300 rounded"
          />
          {errors.email && (
            <div className="text-red-500 text-sm">{errors.email}</div>
          )}
        </div>
        <div className="mb-6 relative">
          <label htmlFor="password" className="block text-gray-700 mb-2">
            Password
          </label>
          <input
            type={passwordVisible ? 'text' : 'password'} // Toggle input type
            name="password"
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            className="w-full px-3 py-2 border border-gray-300 rounded"
          />
          <div
            className="absolute inset-y-0 right-0 pr-3 mt-8 flex items-center text-gray-500 cursor-pointer"
            onClick={() => setPasswordVisible(!passwordVisible)} // Toggle visibility
          >
            {passwordVisible ? < IoEyeOutline size={24} /> : < IoEyeOffOutline size={24} />}
          </div>
          {errors.password && (
            <div className="text-red-500 text-sm">{errors.password}</div>
          )}
        </div>
        <button
          type="submit"
          className="w-full py-2 bg-blue-500 text-white font-bold rounded hover:bg-blue-700 transition duration-200"
        >
          Log in
        </button>
      </form>
    </div>
  );
};

export default Login;
