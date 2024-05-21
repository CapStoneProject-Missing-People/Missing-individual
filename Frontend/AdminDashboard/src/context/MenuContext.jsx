import React,{createContext,useState} from 'react'; 

export const MenuContext = createContext(); 

const MenuContextProvider = ({children})=>{
    const [isOpen,setIsOpen] = useState(false);

    const toggleMenu = () => setIsOpen(!isOpen); 
    
    return (
        <MenuContext.Provider value={{isOpen,toggleMenu}}>
            {children}
        </MenuContext.Provider>
    )
}
export default MenuContextProvider; 
