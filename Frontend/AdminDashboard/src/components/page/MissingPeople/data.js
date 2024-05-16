import { Description } from "@headlessui/react";

const userData = [
    { 
      id: 1,
      name: "John", 
      email: "john@example.com", 
      age: 30, 
      image: 'https://bit.ly/3I9nL2D', 
      status:'pending' ,
      description:"tall, wore white shirt"
    },
    { 
      id: 2,
      name: "Alice", 
      email: "alice@example.com", 
      age: 25, 
      image: 'https://bit.ly/3I9nL2D',
      status:'pending',
      description:"short, wore white shirt" 
    },
    { 
      id: 3,
      name: "Bob",  
      email: "bob@example.com", 
      age: 35,
      image: 'https://bit.ly/3I9nL2D', 
      status:'pending',
      description:"tall, wore red shirt"
    },
    { 
      id: 6,
      name: "leul", 
      email: "john@example.com", 
      age: 30, 
      image: 'https://bit.ly/3I9nL2D', 
      status:'pending',
      description:"medium, wore black shirt"
    },
    { 
      id: 5,
      name: "dave", 
      email: "alice@example.com", 
      age: 25, 
      image: 'https://bit.ly/3I9nL2D',
      status:'pending',
      description:"tall, wore white shirt" 
    },
    { 
      id: 4,
      name: "kaleb", 
      email: "bob@example.com", 
      age: 35,
      image: 'https://bit.ly/3I9nL2D', 
      status:'pending',
      description:"medium, wore white shirt"
    },

  ];
  

  export const fetchDataById = (id) => {
    const user = userData.find((item) => item.id === id);
    return user || {};
  };