import React from 'react';
import DataFetchingComponent from './DataFetchingComponent'; // Make sure the path is correct

const TableComponentPresentation = () => {
  return (
    <div className="flex flex-col overflow-auto py-4 sm:py-0">
      <DataFetchingComponent />
    </div>
  );
};

export default TableComponentPresentation;
