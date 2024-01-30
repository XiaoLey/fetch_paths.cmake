cmake_minimum_required(VERSION 3.6)

set(FETCH_PATHS_VERSION_MAJOR 0)
set(FETCH_PATHS_VERSION_MINOR 1)
set(FETCH_PATHS_VERSION_PATCH 0)

# print version
if (NOT FETCH_PATHS_LIST OR NOT "${CMAKE_CURRENT_LIST_FILE}" IN_LIST FETCH_PATHS_LIST)
    message(STATUS "Loading fetch_paths.cmake: ${CMAKE_CURRENT_LIST_FILE} (version: \"${FETCH_PATHS_VERSION_MAJOR}.${FETCH_PATHS_VERSION_MINOR}.${FETCH_PATHS_VERSION_PATCH}\")")
    list(APPEND path_list ${FETCH_PATHS_LIST} "${CMAKE_CURRENT_LIST_FILE}")
    set(FETCH_PATHS_LIST "${path_list}" CACHE INTERNAL "The list of loaded files" FORCE)
    unset(path_list)
endif ()


# clear the exclusion list
macro(_fetch_paths_clear_exc_var exc_var_var)
    if (DEFINED ${exc_var_var} AND NOT "${${exc_var_var}}" STREQUAL "")
        unset(${${exc_var_var}})
    endif ()
endmacro()


# normalizing paths
macro(_fetch_paths_normalize_path normalize_var default_vlue)
    if (NOT DEFINED ${normalize_var} OR "${${normalize_var}}" STREQUAL "")
        if (NOT DEFINED ${default_vlue})
            message(FATAL_ERROR "${default_vlue} is not defined")
        endif ()
        set(${normalize_var} "${${default_vlue}}")
    elseif (NOT IS_ABSOLUTE "${${normalize_var}}")
        if (NOT DEFINED ${default_vlue})
            message(FATAL_ERROR "${default_vlue} is not defined")
        endif ()
        set(${normalize_var} "${${default_vlue}}/${${normalize_var}}")
    endif ()
endmacro()


# define filter lists
macro(_fetch_paths_define_filter_lists output_filter_list exclude_list_filter_list is_directory)
    # define ${output_filter_list}
    if (NOT DEFINED ${output_filter_list})
        if (${is_directory})
            list(APPEND ${output_filter_list} ".*")
        else ()
            list(APPEND ${output_filter_list} ".+\\.(c|cpp|cc|cxx|C)$")
        endif ()
    endif ()

    # define ${exclude_list_filter_list}
    if (NOT DEFINED ${exclude_list_filter_list})
        list(APPEND ${exclude_list_filter_list} ".*")
    endif ()
endmacro()


# filter list by regexes
function(_fetch_paths_filter_list input_list filter_list output_list)
    list(LENGTH ${input_list} _length)
    set(_temp_list "${${input_list}}") # copy list
    set(_temp_output_files "")
    foreach (_regex IN LISTS ${filter_list})
        if ("${${input_list}}" STREQUAL "")
            break()
        endif ()
        if ("${_regex}" STREQUAL "")
            continue()
        endif ()
        list(FILTER _temp_list INCLUDE REGEX "${_regex}")
        list(APPEND _temp_output_files ${_temp_list})
        list(REMOVE_ITEM ${input_list} ${_temp_list})
        set(_temp_list "${${input_list}}") # copy list
    endforeach ()

    # check if it is correct.
    list(LENGTH ${input_list} _length2)
    list(LENGTH _temp_output_files _length3)
    math(EXPR _length2 "${_length2} + ${_length3}")
    if (NOT _length EQUAL _length2)
        message(FATAL_ERROR "Error occurred during matching")
    endif ()

    set(${output_list} "${_temp_output_files}" PARENT_SCOPE)
endfunction()


function(fetch_paths output_var)
    if (NOT DEFINED output_var OR "${output_var}" STREQUAL "")
        message(FATAL_ERROR "output_var is empty")
    endif ()

    set(options APPEND DISABLE_RECURSION DIRECTORY)
    set(oneValueArgs RELATIVE_PATH WORKING_DIRECTORY EXCLUDE_LIST_VAR)
    set(multiValueArgs OUTPUT_FILTER_LIST EXCLUDE_FILTER_LIST EXCLUDE_LIST_FILTER_LIST)

    cmake_parse_arguments(fetch_paths "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # clear EXCLUDE_LIST_VAR
    _fetch_paths_clear_exc_var(fetch_paths_EXCLUDE_LIST_VAR)

    # define RELATIVE_PATH
    _fetch_paths_normalize_path(fetch_paths_RELATIVE_PATH CMAKE_CURRENT_SOURCE_DIR)

    # define WORKING_DIRECTORY
    _fetch_paths_normalize_path(fetch_paths_WORKING_DIRECTORY CMAKE_CURRENT_SOURCE_DIR)

    # define OUTPUT_FILTER_LIST and EXCLUDE_LIST_FILTER_LIST
    _fetch_paths_define_filter_lists(fetch_paths_OUTPUT_FILTER_LIST fetch_paths_EXCLUDE_LIST_FILTER_LIST fetch_paths_DIRECTORY)

    # if disable recursion is enabled, get the file list without recursion, else get the file list recursively.
    if (fetch_paths_DISABLE_RECURSION)
        file(GLOB file_paths LIST_DIRECTORIES ${fetch_paths_DIRECTORY} RELATIVE "${fetch_paths_RELATIVE_PATH}"
             "${fetch_paths_WORKING_DIRECTORY}/*")
    else ()
        file(GLOB_RECURSE file_paths LIST_DIRECTORIES ${fetch_paths_DIRECTORY} RELATIVE "${fetch_paths_RELATIVE_PATH}"
             "${fetch_paths_WORKING_DIRECTORY}/*")
    endif ()

    # check if is match directory, if it is, remove the files in the file list.
    if (fetch_paths_DIRECTORY)
        foreach (file_path IN LISTS file_paths)
            if (NOT IS_DIRECTORY "${fetch_paths_RELATIVE_PATH}/${file_path}")
                list(REMOVE_ITEM file_paths "${file_path}")
            endif ()
        endforeach ()
    endif ()

    # get the output file list.
    if (DEFINED fetch_paths_EXCLUDE_FILTER_LIST)
        foreach (file_path IN LISTS file_paths)
            foreach (_regex IN LISTS fetch_paths_OUTPUT_FILTER_LIST)
                # if the current file matches the filter, add it to the current output list.
                if ("${file_path}" MATCHES "${_regex}")
                    # check if the current file is in the exclusion list, if it is, set _exclude_file to TRUE, and break the loop.
                    set(_exclude_file FALSE)
                    foreach (_EXCLUDE_REGEX IN LISTS fetch_paths_EXCLUDE_FILTER_LIST)
                        if ("${file_path}" MATCHES "${_EXCLUDE_REGEX}")
                            set(_exclude_file TRUE)
                            break()
                        endif ()
                    endforeach ()

                    # if the current file is not in the exclusion list, add it to the current output list, else add it to the exclusion list.
                    if (NOT _exclude_file)
                        list(APPEND output_files_current "${file_path}")
                    elseif (DEFINED fetch_paths_EXCLUDE_LIST_VAR)
                        # add to the exclusion list
                        list(APPEND ${fetch_paths_EXCLUDE_LIST_VAR} "${file_path}")
                    endif ()

                    break()
                endif ()
            endforeach ()
        endforeach ()

        unset(_exclude_file)
    else ()
        foreach (file_path IN LISTS file_paths)
            foreach (_regex IN LISTS fetch_paths_OUTPUT_FILTER_LIST)
                # if the current file matches the filter, add it to the current output list.
                if ("${file_path}" MATCHES "${_regex}")
                    list(APPEND output_files_current "${file_path}") # add to the current output list.
                    break()
                endif ()
            endforeach ()
        endforeach ()
    endif ()

    # sort the output file list by the regexes.
    list(LENGTH output_files_current _length) # get the length of the current output file list.
    if (_length GREATER 1)
        list(LENGTH fetch_paths_OUTPUT_FILTER_LIST _length) # get the length of the output filter list.
        if (_length GREATER 1)
            _fetch_paths_filter_list(output_files_current fetch_paths_OUTPUT_FILTER_LIST _temp_output_files)
            set(output_files_current "${_temp_output_files}")
        endif ()
    endif ()

    # remove the files in the exclusion list from the output file list.
    if (DEFINED fetch_paths_EXCLUDE_LIST_VAR AND DEFINED fetch_paths_EXCLUDE_LIST_FILTER_LIST)
        _fetch_paths_filter_list(${fetch_paths_EXCLUDE_LIST_VAR} fetch_paths_EXCLUDE_LIST_FILTER_LIST _temp_exclude_files)
        set(${fetch_paths_EXCLUDE_LIST_VAR} "${_temp_exclude_files}")
    endif ()

    # if append mode is enabled, append the output file list to the existing file list.
    if (fetch_paths_APPEND)
        set(output_files_current "${${output_var}};${output_files_current}")
    endif ()

    # remove empty strings, and set the output file list and the exclusion list.
    list(FILTER output_files_current EXCLUDE REGEX "^$")  # remove empty strings
    set(${output_var} "${output_files_current}" PARENT_SCOPE)
    set(${fetch_paths_EXCLUDE_LIST_VAR} "${${fetch_paths_EXCLUDE_LIST_VAR}}" PARENT_SCOPE)
endfunction()
