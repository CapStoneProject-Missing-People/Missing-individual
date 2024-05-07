import React, { useState } from 'react';

function Feedback() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');
  const [response, setResponse] = useState('');

  const handleSubmit = (event) => {
    event.preventDefault();

  };

  return (
    <div class='w-300 px-5 py-5 inline-block align-middle' >
      <div className=''>
        <h2 class='font-inter text-5xl'>Feedback Form</h2>
        <form onSubmit={handleSubmit}>
          <div class='mt-5'>
            <label htmlFor="name">Name:</label>
            <input
              type="text"
              id="name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
            />
          </div>
          <div class="mt-5">
            <label htmlFor="email">Email:</label>
            <input
              type="email"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div class="mt-5">
            <label htmlFor="message">Message:</label>
            <textarea
              id="message"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              required
            ></textarea>
          </div>
          <div class="mt-5">
            <label htmlFor="response">Admin Response:</label>
            <textarea
              id="response"
              value={response}
              onChange={(e) => setResponse(e.target.value)}
            ></textarea>
          </div>
          <button type="submit" class='bg-sky-500 py-5 mt-5 rounded-2xl font-inter text-xl text-zinc-300'>Submit</button>
        </form>
      </div>
    </div>
  );
}

export default Feedback;
