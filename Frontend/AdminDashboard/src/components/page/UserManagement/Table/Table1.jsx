import React, { useMemo, useState, useEffect } from 'react';
import {
  useTable,
  useSortBy,
  useGlobalFilter,
  usePagination,
} from 'react-table';
import GlobalSearchFilter1 from './GlobalSearchFilter1';
import SelectMenu1 from './SelectMenu1';
import PaginationNav1 from './PaginationNav1';
import TableComponent from './TableComponent';
import axios from 'axios';

const Table = ({ data }) => {
  const [tableData, setTableData] = useState(data);
  const columns = useMemo(
    () => [
      {
        Header: "Name",
        accessor: "name",
        width: "150px",
      },
      {
        Header: "Phone",
        accessor: "phoneNo",
        width: "150px",
      },
      {
        Header: "Email",
        accessor: "email",
        width: "240px",
        disableSortBy: true,
      },
      {
        Header: "Actions",
        accessor: "actions",
        Cell: ({ row }) => (
          <button 
            onClick={() => handleDeleteClick(row.original._id)}
            className="bg-red-600 text-white px-4 py-2 rounded-full"
          >
            Delete
          </button>
        ),
        disableSortBy: true,
        width: "100px",
      },

    ],
    []
  );

  useEffect(()=> {
    // Update the table data whenever the `data` prop changes
    setTableData(data);
  },[data]);
  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
    state,
    setGlobalFilter,
    page,
    pageOptions,
    pageCount,
    gotoPage,
    canPreviousPage,
    canNextPage,
    setPageSize,
  } = useTable(
    {
      columns,
      data: tableData,
      initialState: { pageSize: 5 },
    },
    useGlobalFilter,
    useSortBy,
    usePagination
  );

  const { globalFilter, pageIndex, pageSize } = state;

  const handleDeleteClick = async (_id) => {

    try {
    const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
    
    // Include token in request headers
    const headers = {
      Authorization: `Bearer ${token}`,
    };
      // Send a DELETE request to the backend endpoint
      await axios.delete(`http://localhost:4000/api/admin/deleteUser/${_id}`, { headers });

      // If the request is successful, update the state to remove the deleted row
      setTableData(prevData => prevData.filter(row => row._id !== _id));
      
    } catch (error) {
      console.error("Error deleting row:", error);
    }
  };

  return (
    <div className="w-full flex flex-col gap-4">
      <div className="flex flex-col sm:flex-row justify-between gap-2">
        <GlobalSearchFilter1
          className="sm:w-64"
          globalFilter={globalFilter}
          setGlobalFilter={setGlobalFilter}
        />
        <SelectMenu1
          className="sm:w-44"
          value={pageSize}
          setValue={setPageSize}
          options={[
            { id: 5, caption: "5 items per page" },
            { id: 10, caption: "10 items per page" },
            { id: 20, caption: "20 items per page" },
          ]}
        />
      </div>
      <TableComponent
        getTableProps={getTableProps}
        headerGroups={headerGroups}
        getTableBodyProps={getTableBodyProps}
        rows={rows}
        prepareRow={prepareRow}

      />
      <div className="flex justify-center">
        <PaginationNav1
          gotoPage={gotoPage}
          canPreviousPage={canPreviousPage}
          canNextPage={canNextPage}
          pageCount={pageCount}
          pageIndex={pageIndex}
        />
      </div>
    </div>
  );
};

export default Table;
