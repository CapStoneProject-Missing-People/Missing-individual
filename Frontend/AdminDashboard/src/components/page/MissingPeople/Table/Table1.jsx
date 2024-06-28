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
import Modals from './Modal';
import axios from 'axios';

const Table = ({ data }) => {
  const [tableData, setTableData] = useState(data);
  const [showModal, setShowModal] = useState(false);
  const [currentId, setCurrentId] = useState(null);

  const columns = useMemo(
    () => [
      {
        Header: "ID",
        accessor: "_id",
        width: "100px",
      },
      {
        Header: 'Name',
        accessor: row => `${row.name.firstName} ${row.name.middleName} ${row.name.lastName}`,
        id: 'name', // Provide a unique ID for the accessor
        width: '320px',
      },
      {
        Header: 'Gender',
        accessor: 'gender',
        width: '100px',
        disableSortBy: true,
      },
      {
        Header: 'Age',
        accessor: 'age',
        width: '100px',
      },
      {
        Header: 'Description',
        accessor: 'description',
        width: '300px',
        disableSortBy: true,
      },
      
      {
        Header: 'Status',
        accessor: 'missing_case_id.status',
        width: '100px',
        Cell: ({ value }) => (
          <span className={`text-sm font-medium ${value === 'missing' ? 'text-red-600' : 'text-green-600'}`}>
            {value}
          </span>
        ),
      },
      {
        Header: 'Date Reported',
        accessor: 'missing_case_id.dateReported',
        width: '200px',
        disableSortBy: true,
        Cell: ({ value }) => new Date(value).toLocaleDateString(),
      },
      {
        Header: "Delete Post",
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

  useEffect(() => {
    // Update the table data whenever the `data` prop changes
    setTableData(data);
  }, [data]);

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

  const handleDeleteClick = (_id) => {
    setCurrentId(_id);
    setShowModal(true);
  };

  const confirmDelete = async () => {
    setShowModal(false);
    try {
      const token = document.cookie.split('; ').find(row => row.startsWith('jwt=')).split('=')[1];
      // Include token in request headers
      const headers = {
        Authorization: `Bearer ${token}`,
      };
      // Send a DELETE request to the backend endpoint
      await axios.delete(`http://localhost:4000/api/admin/deletePost/${currentId}`, { headers });
      // If the request is successful, update the state to remove the deleted row
      setTableData((prevData) => prevData.filter((row) => row._id !== currentId));
    } catch (error) {
      console.error("Error deleting row:", error);
    }
  };

  return (
    <div className="w-full flex flex-col items-center gap-4">
      <div className="w-full flex flex-col sm:flex-row justify-between gap-2">
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
            { id: 5, caption: "5 persons per page" },
            { id: 10, caption: "10 persons per page" },
            { id: 20, caption: "20 persons per page" },
          ]}
        />
      </div>
      <TableComponent
        getTableProps={getTableProps}
        headerGroups={headerGroups}
        getTableBodyProps={getTableBodyProps}
        rows={page}
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
      <Modals
        show={showModal}
        onClose={() => setShowModal(false)}
        onConfirm={confirmDelete}
      />
    </div>
  );
};

export default Table;
