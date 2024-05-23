import React, { StrictMode } from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import "./index.css";
import App from "./App";
import MenuContextProvider from "./context/MenuContext";

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <BrowserRouter>
    <StrictMode>
      <MenuContextProvider>
        <App />
      </MenuContextProvider>
    </StrictMode>
  </BrowserRouter>
);