import React, { useMemo, Fragment } from 'react';
import { Listbox, Transition } from '@headlessui/react';
import { FaChevronDown, FaCheck } from 'react-icons/fa';

function SelectMenu1({ value, setValue, options, className = "", disabled }) {
  const selectedOption = useMemo(
    () => options.find((o) => o.id === value),
    [options, value]
  );

  return (
    <Listbox value={value} onChange={setValue} disabled={disabled}>
      <div className={`relative w-full ${className}`}>
        <Listbox.Button
          className={`relative w-full rounded-xl py-3 pl-3 pr-10 text-base text-gray-700 text-left  shadow-md  focus:outline-none ${
            disabled ? "bg-gray-200 cursor-not-allowed" : "bg-white cursor-default"
          }`}
        >
          <span className="block truncate">{selectedOption?.caption}</span>
          <span className="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
            <FaChevronDown size="0.80rem" className="text-gray-400" aria-hidden="true" />
          </span>
        </Listbox.Button>
        <Transition
          as={Fragment}
          leave="transition ease-in duration-100"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <Listbox.Options className="absolute z-10 mt-1 max-h-60 w-full overflow-auto rounded-xl bg-white text-base border shadow-md focus:outline-none">
            {options.map((option) => (
              <Listbox.Option
                key={option.id}
                className={({ active }) => `relative cursor-default select-none py-3 pl-10 pr-4 ${active ? "bg-sky-100" : ""}`}
                value={option.id}
              >
                {({ selected }) => (
                  <>
                    <span className={`block truncate ${selected ? "font-medium" : "font-normal"}`}>
                      {option.caption}
                    </span>
                    {selected ? (
                      <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-red-400">
                        <FaCheck size="0.5rem" aria-hidden="true" />
                      </span>
                    ) : null}
                  </>
                )}
              </Listbox.Option>
            ))}
          </Listbox.Options>
        </Transition>
      </div>
    </Listbox>
  );
}

export default SelectMenu1;
