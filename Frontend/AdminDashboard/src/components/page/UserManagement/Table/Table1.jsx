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
import Modal from './Modal';
import axios from 'axios';
import Cookies from 'js-cookie';

const Table = ({ data }) => {
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
    const isSuperAdmin = loggedInUserRole === 'superAdmin';
    const cols = [
      {
        Header: "Name",
        accessor: "name",
        width: "180px",
      },
      {
        Header: "Phone",
        accessor: "phoneNo",
        width: "180px",
        disableSortBy: true,
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
    ];
    if (isSuperAdmin) {
      cols.splice(3, 0, {
        Header: "Admin Privilege",
        accessor: "adminPrivilege",
        Cell: ({ row }) => (
          <button 
            onClick={() => handleAdminPrivilegeToggle(row.original._id, row.original.role)}
            className={`px-4 py-2 rounded-full ${
              row.original.role === 'admin' ? "bg-green-600" : "bg-red-600"
            } text-white`}
          >
            {row.original.role === 'admin' ? "On" : "Off"}
          </button>
        ),
        disableSortBy: true,
        width: "150px",
      });
    }
    return cols;
  }, [loggedInUserRole]);

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
      const token = Cookies.get('jwt');
      const headers = {
        Authorization: `Bearer ${token}`,
      };
      await axios.delete(`http://localhost:4000/api/admin/deleteUser/${currentId}`, { headers });
      setTableData(prevData => prevData.filter(row => row._id !== currentId));
    } catch (error) {
      console.error("Error deleting row:", error);
    }
  };

  const handleAdminPrivilegeToggle = async (_id, currentRole) => {
    try {
      const token = Cookies.get('jwt');
      const headers = {
        Authorization: `Bearer ${token}`,
      };
      const newRole = currentRole === 'admin' ? 'user' : 'admin';
      const response = await axios.put(`http://localhost:4000/api/admin/updateRole/${_id}`, { role: newRole }, { headers });
      if (response.data) {
        // Filter out the row with the specified _id and update the table data
        setTableData(prevData => prevData.map(row => row._id === _id ? { ...row, role: newRole } : row));
      }
    } catch (error) {
      console.error("Error updating user role:", error);
    }
  };

  return (
    <div className="w-full flex flex-col items-center gap-4">
      <div className="w-full max-w-[60rem] flex flex-col sm:flex-row justify-between gap-2">
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
            { id: 5, caption: "5 users per page" },
            { id: 10, caption: "10 users per page" },
            { id: 20, caption: "20 users per page" },
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
      <Modal 
        show={showModal}
        onClose={() => setShowModal(false)}
        onConfirm={confirmDelete}
      />
    </div>
  );
};

export default Table;
