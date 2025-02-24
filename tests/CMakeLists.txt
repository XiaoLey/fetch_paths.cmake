include(${FETCH_PATHS_CMAKE_DIR}/fetch_paths.cmake)

# Ensure global variables INDEX and TOTAL_TESTS
set(INDEX 0 CACHE INTERNAL "Current test index")
set(TOTAL_TESTS 0 CACHE INTERNAL "Total test count")

# Increment the total test count manually
function(add_test_count count)
    math(EXPR TOTAL_TESTS "${TOTAL_TESTS} + ${count}")
    set(TOTAL_TESTS ${TOTAL_TESTS} CACHE INTERNAL "")
endfunction()

# Output function with dynamic progress including total tests
function(output_test_result result msg)
    math(EXPR INDEX "${INDEX} + 1")         # Increment global INDEX
    set(INDEX ${INDEX} CACHE INTERNAL "")   # Update global INDEX

    if (result)
        message("[${INDEX}/${TOTAL_TESTS}]\tpassed - ${msg}")
    else()
        message(FATAL_ERROR "[${INDEX}/${TOTAL_TESTS}]\tfailed - ${msg}")
    endif()
endfunction()

# Check if a string exists in a list
function(check_strs_exists list_var)
    foreach (var IN LISTS ARGN)
        if (NOT "${var}" IN_LIST ${list_var})
            output_test_result(FALSE "\"${var}\" not found in `${list_var}`")
        endif ()
    endforeach ()
    output_test_result(TRUE "Found in `${list_var}`: \"${ARGN}\"")
endfunction()

# Check if a string does not exist in a list
function(check_strs_not_exists list_var)
    foreach (var IN LISTS ARGN)
        if ("${var}" IN_LIST ${list_var})
            output_test_result(FALSE "\"${var}\" should not exist in `${list_var}`")
        endif ()
    endforeach ()
    output_test_result(TRUE "Not found in `${list_var}`: \"${ARGN}\"")
endfunction()

# Check if the length of a list is equal to a given length
function(check_list_length list_var length)
    list(LENGTH ${list_var} len)
    if (NOT len EQUAL ${length})
        output_test_result(FALSE "Expected length of `${list_var}` is ${length}, got ${len}")
    endif ()
    output_test_result(TRUE "Length of `${list_var}` is ${len}")
endfunction()

# Check if the order of strings in a list is the same as the given order
function(check_list_order list_var)
    # Copy the list
    set(_original_list "${${list_var}}")
    set(_remaining_list "${${list_var}}")

    foreach(_expected IN LISTS ARGN)
        # Search for _expected in the current remaining list
        list(FIND _remaining_list "${_expected}" _idx)

        if(_idx EQUAL -1)
            # If not found, confirm it exists in the original list
            list(FIND _original_list "${_expected}" _full_idx)
            if(_full_idx EQUAL -1)
                output_test_result(FALSE "Order check failed: \"${_expected}\" does not exist in `${list_var}` at all.")
            else()
                output_test_result(FALSE "Order check failed: \"${_expected}\" is in `${list_var}`, but not in the correct order.")
            endif()
            return()
        endif()

        # Dynamically handle list removal method based on CMake version
        if(CMAKE_VERSION VERSION_LESS "3.12")
            # Use RANGE approach for older CMake versions
            list(REMOVE_AT _remaining_list RANGE 0 ${_idx})
        else()
            # Use SUBLIST approach for CMake 3.12 and above
            list(LENGTH _remaining_list _len)
            math(EXPR _start "${_idx} + 1")
            if(_start GREATER_EQUAL _len)
                set(_remaining_list "")
            else()
                list(SUBLIST _remaining_list ${_start} -1 _remaining_list)
            endif()
        endif()
    endforeach()

    # If all expected elements are found in the expected order, the check passes
    output_test_result(TRUE "Order check passed for `${list_var}`: \"${ARGN}\"")
endfunction()

# Pre-compute the total number of tests
add_test_count(39)

# Check if the source files are fetched recursively
fetch_paths(files)
check_strs_exists(files a.c b.cpp folder1/file1.cpp folder2/folder3/file3.c folder2/folder3/file3.cpp)
check_list_length(files 5)

unset(files)

# Check if the `DISABLE_RECURSION` option is working correctly
fetch_paths(files DISABLE_RECURSION)
check_strs_exists(files a.c b.cpp)
check_list_length(files 2)

unset(files)

# Check if the `RELATIVE_PATH` option is working correctly
fetch_paths(files RELATIVE_PATH "${CMAKE_SOURCE_DIR}" DISABLE_RECURSION)
check_strs_exists(files tests/a.c tests/b.cpp)
check_list_length(files 2)

unset(files)

# Check if the `DIRECTORY` option is working correctly
fetch_paths(files DIRECTORY)
check_strs_exists(files folder1 folder2 folder2/folder3 folder2/folder3/folder4)
check_list_length(files 4)

unset(files)

# Check if `DIRECTORY` and `DISABLE_RECURSION` are working together correctly
fetch_paths(files DIRECTORY DISABLE_RECURSION)
check_strs_exists(files folder1 folder2)
check_list_length(files 2)

unset(files)

# Check if the `OUTPUT_FILTER_LIST` is working correctly
fetch_paths(files DIRECTORY OUTPUT_FILTER_LIST "^[^/]+/[^/]+$")
check_strs_exists(files folder2/folder3)
check_strs_not_exists(files folder1 folder2 folder2/folder3/folder4)
check_list_length(files 1)

unset(files)

# Check if the `EXCLUDE_FILTER_LIST` is working correctly
fetch_paths(files EXCLUDE_LIST_VAR exc_files EXCLUDE_FILTER_LIST "\.cpp$")
check_strs_exists(files a.c folder2/folder3/file3.c)
check_strs_not_exists(files b.cpp folder1/file1.cpp folder2/folder3/file3.cpp)
check_strs_exists(exc_files b.cpp folder1/file1.cpp folder2/folder3/file3.cpp)
check_list_length(files 2)
check_list_length(exc_files 3)

unset(files)
unset(exc_files)

# Check if the `OUTPUT_FILTER_LIST` and `EXCLUDE_FILTER_LIST` are working together correctly
fetch_paths(files OUTPUT_FILTER_LIST "\.h$" "\.hpp$" EXCLUDE_LIST_VAR exc_files EXCLUDE_FILTER_LIST "^a\.h$")
check_list_order(files folder2/folder3/file3.h b.hpp)
check_strs_exists(files folder2/folder3/file3.h b.hpp)
check_list_length(files 2)
check_strs_exists(exc_files a.h)
check_list_length(exc_files 1)

unset(files)
unset(exc_files)

# Check if `OUTPUT_FILTER_LIST`, `EXCLUDE_FILTER_LIST` and `DISABLE_RECURSION` are working together correctly
fetch_paths(files OUTPUT_FILTER_LIST ".[^c]+$" "\.c$" EXCLUDE_LIST_VAR exc_files EXCLUDE_FILTER_LIST "CMakeLists\.txt$" DISABLE_RECURSION)
check_strs_exists(files a.c b.cpp a.h b.hpp)
check_list_order(files a.h a.c)
check_strs_not_exists(files CMakeLists.txt)
check_strs_exists(exc_files CMakeLists.txt)
check_list_length(files 4)
check_list_length(exc_files 1)

unset(files)
unset(exc_files)

# Check if the `EXCLUDE_LIST_FILTER_LIST` is working correctly
fetch_paths(files EXCLUDE_LIST_VAR exc_files EXCLUDE_FILTER_LIST "\.cpp$" EXCLUDE_LIST_FILTER_LIST "^[^/]+$")
check_strs_exists(files a.c folder2/folder3/file3.c)
check_strs_not_exists(files b.cpp folder1/file1.cpp folder2/folder3/file3.cpp)
check_strs_exists(exc_files b.cpp)
check_strs_not_exists(exc_files folder1/file1.cpp folder2/folder3/file3.cpp)

unset(files)
unset(exc_files)

# Check if the `APPEND` option is working correctly
fetch_paths(files OUTPUT_FILTER_LIST "\.h$|\.hpp$")
fetch_paths(files OUTPUT_FILTER_LIST "\.h$|\.hpp$" APPEND)
check_list_length(files 6)
list(REMOVE_DUPLICATES files)
check_list_length(files 3)
fetch_paths(files OUTPUT_FILTER_LIST ".*")
fetch_paths(files DIRECTORY APPEND)
check_list_length(files 15)
list(REMOVE_DUPLICATES files)
check_list_length(files 15)

unset(files)

# Check if the sorting function is working correctly
fetch_paths(files OUTPUT_FILTER_LIST "\.h$" "\.hpp$")
check_list_order(files a.h folder2/folder3/file3.h b.hpp)
fetch_paths(files OUTPUT_FILTER_LIST "\.h$|\.hpp$")
check_list_order(files a.h b.hpp folder2/folder3/file3.h)

unset(files)
