import React, { useMemo, useState, useEffect } from 'react';
import { useTable, useSortBy, useGlobalFilter, usePagination } from 'react-table';
import GlobalSearchFilter1 from './GlobalSearchFilter1';
import SelectMenu1 from './SelectMenu1';
import PaginationNav1 from './PaginationNav1';
import TableComponent from './TableComponent';
import Modal from './Modal';
import axios from 'axios';
import Cookies from 'js-cookie';

const Table1 = ({ data }) => {
  const [tableData, setTableData] = useState(data);
  const [showModal, setShowModal] = useState(false);
  const [currentId, setCurrentId] = useState(null);
  const [loggedInUserRole, setLoggedInUserRole] = useState(null);

  useEffect(() => {
    const fetchLoggedInUserRole = async () => {
      try {
        const token = Cookies.get('jwt');
        const response = await axios.get('http://localhost:4000/api/profile/current', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setLoggedInUserRole(response.data.role);
      } catch (error) {
        console.error('Error fetching logged-in user data:', error);
      }
    };
    fetchLoggedInUserRole();
  }, []);

  const columns = useMemo(() => {
    const cols = [
      {
        Header: "Timestamp",
        accessor: "timestamp",
        Cell: ({ value }) => new Date(value).toLocaleString(),
      },
      {
        Header: "Action",
        accessor: "action",
      },
      {
        Header: "User ID",
        accessor: "user_id",
      },
      {
        Header: "User Agent",
        accessor: "user_agent",
      },
      {
        Header: "Method",
        accessor: "method",
      },
      {
        Header: "IP",
        accessor: "ip",
      },
      {
        Header: "Status",
        accessor: "status",
      },
      {
        Header: "Error",
        accessor: "error",
        Cell: ({ value }) => value || '-',
      },
      {
        Header: "Log Level",
        accessor: "logLevel",
      },
    ];
    return cols;
  }, []);

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

  return (
    <div className="w-full flex flex-col items-center gap-4">
      <div className="w-full  flex flex-col sm:flex-row justify-between gap-2">
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
            { id: 5, caption: "5 logs per page" },
            { id: 10, caption: "10 logs per page" },
            { id: 20, caption: "20 logs per page" },
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
    </div>
  );
};

export default Table1;
