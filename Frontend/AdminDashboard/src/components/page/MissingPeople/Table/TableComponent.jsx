import React, { useState } from 'react';
import { FaSortUp, FaSortDown } from 'react-icons/fa';
import Avatar from './Avatar';
import EditModal from './EditModal'; // Import the modal component

function TableComponent({
  getTableProps,
  headerGroups,
  getTableBodyProps,
  rows,
  prepareRow,
  pageSize,
}) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);

  const handleRowClick = (row) => {
    setSelectedUser(row.original);
    setIsModalOpen(true);
  };

  return (
    <div className="w-full flex justify-center">
      <div className="w-full p-4 bg-white rounded-xl shadow-[0_4px_10px_rgba(0,0,0,0.03)] overflow-x-auto">
        <table {...getTableProps()} className="w-full">
          <thead>
            {headerGroups.map((headerGroup) => (
              <tr {...headerGroup.getHeaderGroupProps()}>
                {headerGroup.headers.map((column) => (
                  <th
                    {...column.getHeaderProps(column.getSortByToggleProps())}
                    className="px-3 text-start text-xs font-light uppercase cursor-pointer"
                    style={{ width: column.width }}
                  >
                    <div className="flex gap-2 items-center">
                      <div className="text-gray-600">
                        {column.render("Header")}
                      </div>
                      {!column.disableSortBy && (
                        <div className="flex flex-col text-gray-600">
                          <FaSortUp
                            size="0.40rem"
                            className={`${
                              column.isSorted
                                ? column.isSortedDesc
                                  ? "text-gray-300"
                                  : "text-gray-600"
                                : ""
                            }`}
                          />
                          <FaSortDown
                            size="0.40rem"
                            className={`-translate-y-1/2 ${
                              column.isSorted
                                ? column.isSortedDesc
                                  ? "text-gray-600"
                                  : "text-gray-300"
                                : ""
                            }`}
                          />
                        </div>
                      )}
                    </div>
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody {...getTableBodyProps()}>
            {rows.map((row) => {
              prepareRow(row);
              return (
                <tr
                  {...row.getRowProps()}
                  className="py-1 border-b last:border-none cursor-pointer"
                  onClick={() => handleRowClick(row)}
                >
                  {row.cells.map((cell) => {
                    return (
                      <td {...cell.getCellProps()} className="p-4">
                        {cell.column.id === "name" ? (
                          <div className="flex gap-2 items-center">
                            <Avatar
                              src={cell.row.original.imageUrl}
                              name={cell.row.original.name}
                            />
                            {cell.render("Cell")}
                          </div>
                        ) : cell.column.id === 'description' ? (
                          <span>
                            {cell.value.length > 15
                              ? cell.value.slice(0, 15) + '...'
                              : cell.value}
                          </span>
                        ) : (
                          cell.render("Cell")
                        )}
                      </td>
                    );
                  })}
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      {isModalOpen && (
        <EditModal
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          user={selectedUser}
        />
      )}
    </div>
  );
}

export default TableComponent;
