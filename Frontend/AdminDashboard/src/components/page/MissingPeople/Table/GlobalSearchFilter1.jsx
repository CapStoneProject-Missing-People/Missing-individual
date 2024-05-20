import React from 'react';
import { FaSearch } from 'react-icons/fa';
import InputGroup7 from './InputGroup7';

function GlobalSearchFilter1({ globalFilter, setGlobalFilter, className = "" }) {
  return (
    <InputGroup7
      name="search"
      value={globalFilter || ""}
      onChange={(e) => setGlobalFilter(e.target.value || undefined)}
      label="Search"
      decoration={<FaSearch size="1rem" className="text-gray-400" />}
      className={className}
    />
  );
}

export default GlobalSearchFilter1;
