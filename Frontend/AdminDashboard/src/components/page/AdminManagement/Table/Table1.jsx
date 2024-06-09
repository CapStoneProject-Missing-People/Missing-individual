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
    const isSuperAdmin = loggedInUserRole === 5150;
    const cols = [
      {
        Header: "Name",
        accessor: "name",
      },
      {
        Header: "Phone",
        accessor: "phoneNo",
        disableSortBy: true,
      },
      {
        Header: "Email",
        accessor: "email",
        disableSortBy: true,
      },
      {
        Header: "Admin Privilege",
        accessor: "adminPrivilege",
        Cell: ({ row }) => (
          <button 
            onClick={() => handleAdminPrivilegeToggle(row.original._id, row.original.role)}
            className={`px-4 py-2 rounded-full ${
              row.original.role === 3244 ? "bg-green-600" : "bg-red-600"
            } text-white`}
          >
            {row.original.role === 3244 ? "On" : "Off"}
          </button>
        ),
        disableSortBy: true,
      },
      {
        Header: "Read",
        accessor: "read",
        Cell: ({ row }) => (
          <button 
            onClick={() => handlePermissionToggle(row.original, 'read')}
            className={`px-4 py-2 rounded-full ${
              row.original.permissions.includes('read') ? "bg-blue-600" : "bg-gray-400"
            } text-white`}
          >
            Read
          </button>
        ),
        disableSortBy: true,
      },
      {
        Header: "Update",
        accessor: "update",
        Cell: ({ row }) => (
          <button 
            onClick={() => handlePermissionToggle(row.original, 'update')}
            className={`px-4 py-2 rounded-full ${
              row.original.permissions.includes('update') ? "bg-yellow-600" : "bg-gray-400"
            } text-white`}
          >
            Update
          </button>
        ),
        disableSortBy: true,
      },
      {
        Header: "Remove",
        accessor: "remove",
        Cell: ({ row }) => (
          <button 
            onClick={() => handlePermissionToggle(row.original, 'delete')}
            className={`px-4 py-2 rounded-full ${
              row.original.permissions.includes('delete') ? "bg-red-600" : "bg-gray-400"
            } text-white`}
          >
            Remove
          </button>
        ),
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
      },
    ];
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
      await axios.delete(`http://localhost:4000/api/admin/deleteAdmin/${currentId}`, { headers });
      setTableData(prevData => prevData.filter(row => row._id !== currentId));
      console.log("show:",tableData)
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
      const newRole = currentRole === 3244 ? 2001 : 3244;
      const response = await axios.patch(`http://localhost:4000/api/admin/updateRole/${_id}`, { role: newRole }, { headers });
      console.log('updating.');
      if (response.data) {
        // Filter out the row with the specified _id and update the table data
        setTableData(prevData => prevData.map(row => row._id === _id ? { ...row, role: newRole } : row));
      }
    } catch (error) {
      console.error("Error updating user role:", error);
    }
  };

  const handlePermissionToggle = async (user, permission) => {
    try {
      const token = Cookies.get('jwt');
      const headers = {
        Authorization: `Bearer ${token}`,
      };
      
      // Find the current user's permissions
      const currentPermissions = user.permissions;
  
      // Toggle the permission
      const newPermissions = currentPermissions.includes(permission)
        ? currentPermissions.filter(perm => perm !== permission)
        : [...currentPermissions, permission];
        console.log("please: ",newPermissions)
  
      // Update the permissions in the backend
      const response = await axios.patch(`http://localhost:4000/api/admin/updatePermissions/${user._id}`, { permissions: newPermissions }, { headers });
  
      if(response.data) {
        // Update the local state with the new permissions
        setTableData(prevData => prevData.map(row => row._id === user._id ? { ...row, permissions: newPermissions } : row));
      }
    } catch (error) {
      console.error("Error updating permissions:", error);
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
            { id: 5, caption: "5 admins per page" },
            { id: 10, caption: "10 admins per page" },
            { id: 20, caption: "20 admins per page" },
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
