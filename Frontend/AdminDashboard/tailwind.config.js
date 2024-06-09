/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html","./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        poppins: "Poppins",
        kaushan: "Kaushan Script",
        Montserrat: ['Inter', 'system-ui', 'Avenir', 'Helvetica', 'Arial', 'sans-serif'],
      },
      scrollbar:{
        DEFAULT:{
          thumb: '#cbd5e0', // Customize thumb color
          track: '#f7fafc', // Customize track color
          width: '8px',
        }
      }
    },
  },
  plugins: [require("@tailwindcss/typography")],
}

