include(fetch_paths)

function(check_strs_exists list_var)
    foreach (var IN LISTS ARGN)
        if (NOT "${var}" IN_LIST ${list_var})
            message(FATAL_ERROR "${var} not found in ${list_var}")
        endif ()
    endforeach ()
    message("passed - `${ARGN}` found in ${list_var}")
endfunction()

function(check_strs_not_exists list_var)
    foreach (var IN LISTS ARGN)
        if ("${var}" IN_LIST ${list_var})
            message(FATAL_ERROR "${var} found in ${list_var}")
        endif ()
    endforeach ()
    message("passed - `${ARGN}` not found in ${list_var}")
endfunction()

function(check_list_length list_var length)
    list(LENGTH ${list_var} len)
    if (NOT len EQUAL ${length})
        message(FATAL_ERROR "${list_var} length not equal to ${length}, actual: ${len}")
    endif ()
    message("passed - ${list_var} length: ${len}")
endfunction()


# fetch "a.c" and "b.cpp"
fetch_paths(files DISABLE_RECURSION)
check_strs_exists(files a.c b.cpp)
check_list_length(files 2)

unset(files)

# fetch "tests/a.c" and "tests/b.cpp"
fetch_paths(files RELATIVE_PATH "${CMAKE_SOURCE_DIR}" DISABLE_RECURSION)
check_strs_exists(files tests/a.c tests/b.cpp)
check_list_length(files 2)

unset(files)

# fetch all direct files (except CMakeLists. txt)
fetch_paths(files OUTPUT_FILTER_LIST ".*" EXCLUDE_FILTER_LIST "CMakeLists\.txt$" EXCLUDE_LIST_VAR exc_files DISABLE_RECURSION)
check_strs_exists(files a.c b.cpp a.h b.hpp)
check_strs_not_exists(files CMakeLists.txt)
check_strs_exists(exc_files CMakeLists.txt)
check_list_length(files 4)
check_list_length(exc_files 1)

unset(files)
unset(exc_files)

# fetch all direct directories
fetch_paths(files DIRECTORY DISABLE_RECURSION)
check_strs_exists(files folder1 folder2)
check_list_length(files 2)

unset(files)

# fetch all source files recursively
fetch_paths(files)
check_strs_exists(files a.c b.cpp folder1/folder1.cpp folder2/folder3/folder3.c folder2/folder3/folder3.cpp)
check_list_length(files 5)

unset(files)

# fetch all c source files recursively
fetch_paths(files EXCLUDE_LIST_VAR exc_files EXCLUDE_FILTER_LIST "\.cpp$")
check_strs_exists(files a.c folder2/folder3/folder3.c)
check_strs_not_exists(files b.cpp folder1/folder1.cpp folder2/folder3/folder3.cpp)
check_strs_exists(exc_files b.cpp folder1/folder1.cpp folder2/folder3/folder3.cpp)
check_list_length(files 2)
check_list_length(exc_files 3)

unset(files)
unset(exc_files)

# fetch all c source files recursively, but the `exc_files` variable contains direct excluded files 
fetch_paths(files EXCLUDE_LIST_VAR exc_files EXCLUDE_FILTER_LIST "\.cpp$" EXCLUDE_LIST_FILTER_LIST "^[^/]+$")
check_strs_exists(files a.c folder2/folder3/folder3.c)
check_strs_not_exists(files b.cpp folder1/folder1.cpp folder2/folder3/folder3.cpp)
check_strs_exists(exc_files b.cpp)
check_strs_not_exists(exc_files folder1/folder1.cpp folder2/folder3/folder3.cpp)

unset(files)
unset(exc_files)

# fetch all directories recursively
fetch_paths(files DIRECTORY)
check_strs_exists(files folder1 folder2 folder2/folder3 folder2/folder3/folder4)
check_list_length(files 4)

unset(files)

# fetch directories in all subdirectories
fetch_paths(files DIRECTORY OUTPUT_FILTER_LIST "^[^/]+/[^/]+$")
check_strs_exists(files folder2/folder3)
check_strs_not_exists(files folder1 folder2 folder2/folder3/folder4)
check_list_length(files 1)

unset(files)

# fetch all files and directories recursively
fetch_paths(files OUTPUT_FILTER_LIST ".*")
fetch_paths(files DIRECTORY APPEND)
check_list_length(files 15)

unset(files)

# fetch all header files recursively but exclude "a.h"
fetch_paths(files OUTPUT_FILTER_LIST "\.h$" "\.hpp$" EXCLUDE_LIST_VAR exc_files EXCLUDE_FILTER_LIST "^a\.h$")
check_strs_exists(files folder2/folder3/folder3.h b.hpp)
check_strs_exists(exc_files a.h)
check_list_length(files 2)
check_list_length(exc_files 1)

unset(files)
unset(exc_files)
