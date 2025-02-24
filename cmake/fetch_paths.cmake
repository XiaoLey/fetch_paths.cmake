cmake_minimum_required(VERSION 3.10)

set(FETCH_PATHS_VERSION_MAJOR 0)
set(FETCH_PATHS_VERSION_MINOR 1)
set(FETCH_PATHS_VERSION_PATCH 6)

# Print version
if (NOT FETCH_PATHS_LIST OR NOT "${CMAKE_CURRENT_LIST_FILE}" IN_LIST FETCH_PATHS_LIST)
    message(STATUS "Loading fetch_paths.cmake: ${CMAKE_CURRENT_LIST_FILE} (version: \"${FETCH_PATHS_VERSION_MAJOR}.${FETCH_PATHS_VERSION_MINOR}.${FETCH_PATHS_VERSION_PATCH}\")")
    list(APPEND path_list ${FETCH_PATHS_LIST} "${CMAKE_CURRENT_LIST_FILE}")
    set(FETCH_PATHS_LIST "${path_list}" CACHE INTERNAL "The list of loaded files" FORCE)
    unset(path_list)
endif ()


# Clear the exclusion list
macro(_fetch_paths_clear_exc_var exc_var_var)
    if (DEFINED ${exc_var_var} AND NOT "${${exc_var_var}}" STREQUAL "")
        unset(${${exc_var_var}})
    endif ()
endmacro()


# Normalizing paths
macro(_fetch_paths_normalize_path normalize_var default_vlue)
    if (NOT DEFINED ${normalize_var} OR "${${normalize_var}}" STREQUAL "")
        if (NOT DEFINED ${default_vlue} OR "${${default_vlue}}" STREQUAL "")
            message(FATAL_ERROR "${default_vlue} is not defined")
        endif ()
        set(${normalize_var} "${${default_vlue}}")
    elseif (NOT IS_ABSOLUTE "${${normalize_var}}")
        if (NOT DEFINED ${default_vlue} OR "${${default_vlue}}" STREQUAL "")
            message(FATAL_ERROR "${default_vlue} is not defined")
        endif ()
        set(${normalize_var} "${${default_vlue}}/${${normalize_var}}")
    endif ()
endmacro()


# Define filter lists
macro(_fetch_paths_define_filter_lists output_filter_list exclude_list_filter_list is_directory)
    if (NOT DEFINED ${output_filter_list} OR "${${output_filter_list}}" STREQUAL "")
        if (${is_directory})
            list(APPEND ${output_filter_list} ".*")
        else ()
            list(APPEND ${output_filter_list} ".+\\.(c|cpp|cc|cxx|C)$")
        endif ()
    endif ()

    if (NOT DEFINED ${exclude_list_filter_list} OR "${${exclude_list_filter_list}}" STREQUAL "")
        list(APPEND ${exclude_list_filter_list} ".*")
    endif ()
endmacro()


# Filter list by regexes
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

    # Check if it is correct
    list(LENGTH ${input_list} _length2)
    list(LENGTH _temp_output_files _length3)
    math(EXPR _length2 "${_length2} + ${_length3}")
    if (NOT _length EQUAL _length2)
        message(FATAL_ERROR "Error occurred during matching")
    endif ()

    set(${output_list} "${_temp_output_files}" PARENT_SCOPE)
endfunction()


# Parse command-line options and return them to the parent scope
macro(_fetch_paths_parse_options)
    set(options APPEND DISABLE_RECURSION DIRECTORY)
    set(oneValueArgs RELATIVE_PATH WORKING_DIRECTORY EXCLUDE_LIST_VAR)
    set(multiValueArgs OUTPUT_FILTER_LIST EXCLUDE_FILTER_LIST EXCLUDE_LIST_FILTER_LIST)

    cmake_parse_arguments(fetch_paths "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
endmacro()


macro(_fetch_paths_prepare_variables)
    # Clean up the exclusion list variable
    _fetch_paths_clear_exc_var(fetch_paths_EXCLUDE_LIST_VAR)

    # Normalize the relative path
    _fetch_paths_normalize_path(fetch_paths_RELATIVE_PATH CMAKE_CURRENT_SOURCE_DIR)

    # Normalize the working directory
    _fetch_paths_normalize_path(fetch_paths_WORKING_DIRECTORY CMAKE_CURRENT_SOURCE_DIR)

    # Define the output and exclusion filter lists
    _fetch_paths_define_filter_lists(fetch_paths_OUTPUT_FILTER_LIST
                                     fetch_paths_EXCLUDE_LIST_FILTER_LIST
                                     fetch_paths_DIRECTORY)
endmacro()


# Collect file list
function(_fetch_paths_collect_file_list outVar)
    # Check fetch_paths_DISABLE_RECURSION to decide recursive listing
    if (${fetch_paths_DISABLE_RECURSION})
        file(GLOB _collected LIST_DIRECTORIES ${fetch_paths_DIRECTORY}
             RELATIVE "${fetch_paths_RELATIVE_PATH}" "${fetch_paths_WORKING_DIRECTORY}/*")
    else()
        file(GLOB_RECURSE _collected LIST_DIRECTORIES ${fetch_paths_DIRECTORY}
             RELATIVE "${fetch_paths_RELATIVE_PATH}" "${fetch_paths_WORKING_DIRECTORY}/*")
    endif()

    # Check if is match directory, if it is, remove the files in the file list
    if (fetch_paths_DIRECTORY)
        foreach (_fp IN LISTS _collected)
            if (NOT IS_DIRECTORY "${fetch_paths_RELATIVE_PATH}/${_fp}")
                list(REMOVE_ITEM _collected "${_fp}")
            endif()
        endforeach()
    endif()

    set(${outVar} "${_collected}" PARENT_SCOPE)
endfunction()


# Apply filters
function(_fetch_paths_apply_filters input_list_name outVar)
    set(_file_paths "${${input_list_name}}")
    set(_output_files_current "")

    # Get the output file list
    if (DEFINED fetch_paths_EXCLUDE_FILTER_LIST AND NOT "${fetch_paths_EXCLUDE_FILTER_LIST}" STREQUAL "")
        foreach (_file_path IN LISTS _file_paths)
            foreach (_regex IN LISTS fetch_paths_OUTPUT_FILTER_LIST)
                # If the current file matches the filter, add it to the current output list
                if ("${_file_path}" MATCHES "${_regex}")
                    # Check if the current file is in the exclusion list, if it is, set _exclude_file to TRUE, and break the loop
                    set(_exclude_file FALSE)
                    foreach (_EXCLUDE_REGEX IN LISTS fetch_paths_EXCLUDE_FILTER_LIST)
                        if ("${_file_path}" MATCHES "${_EXCLUDE_REGEX}")
                            set(_exclude_file TRUE)
                            break()
                        endif ()
                    endforeach ()

                    # If the current file is not in the exclusion list, add it to the current output list, else add it to the exclusion list
                    if (NOT _exclude_file)
                        list(APPEND _output_files_current "${_file_path}")
                    elseif (DEFINED fetch_paths_EXCLUDE_LIST_VAR AND NOT "${fetch_paths_EXCLUDE_LIST_VAR}" STREQUAL "")
                        # Add to the exclusion list
                        list(APPEND ${fetch_paths_EXCLUDE_LIST_VAR} "${_file_path}")
                    endif ()

                    break()
                endif ()
            endforeach ()
        endforeach ()

        unset(_exclude_file)
    else ()
        foreach (_file_path IN LISTS _file_paths)
            foreach (_regex IN LISTS fetch_paths_OUTPUT_FILTER_LIST)
                # If the current file matches the filter, add it to the current output list
                if ("${_file_path}" MATCHES "${_regex}")
                    list(APPEND _output_files_current "${_file_path}") # add to the current output list
                    break()
                endif ()
            endforeach ()
        endforeach ()
    endif ()

    if(DEFINED fetch_paths_EXCLUDE_LIST_VAR AND NOT "${fetch_paths_EXCLUDE_LIST_VAR}" STREQUAL "")
        set(${fetch_paths_EXCLUDE_LIST_VAR} "${${fetch_paths_EXCLUDE_LIST_VAR}}" PARENT_SCOPE)
    endif()

    set(${outVar} "${_output_files_current}" PARENT_SCOPE)
endfunction()


# Exclude list filtering, sorting, and other processing
function(_fetch_paths_handle_exclusion_and_sort inOutVar)
    # Sort the output file list by the regexes
    list(LENGTH ${inOutVar} _length)
    if (_length GREATER 1)
        list(LENGTH fetch_paths_OUTPUT_FILTER_LIST _flength)
        if (_flength GREATER 1)
            _fetch_paths_filter_list(${inOutVar} fetch_paths_OUTPUT_FILTER_LIST _temp_output_files)
            set(${inOutVar} "${_temp_output_files}" PARENT_SCOPE)
        endif()
    endif()

    # Remove the files in the exclusion list from the output file list
    if (DEFINED fetch_paths_EXCLUDE_LIST_VAR AND NOT "${fetch_paths_EXCLUDE_LIST_VAR}" STREQUAL ""
        AND DEFINED fetch_paths_EXCLUDE_LIST_FILTER_LIST AND NOT "${fetch_paths_EXCLUDE_LIST_FILTER_LIST}" STREQUAL "")
        _fetch_paths_filter_list(${fetch_paths_EXCLUDE_LIST_VAR} fetch_paths_EXCLUDE_LIST_FILTER_LIST _temp_exclude_files)
        set(${fetch_paths_EXCLUDE_LIST_VAR} "${_temp_exclude_files}" PARENT_SCOPE)
    endif()
endfunction()


function(fetch_paths output_var)
    if (NOT DEFINED output_var OR "${output_var}" STREQUAL "")
        message(FATAL_ERROR "output_var is empty")
    endif ()

    # Parse command-line options
    _fetch_paths_parse_options(${ARGN})

    # Prepare variables & paths
    _fetch_paths_prepare_variables()

    # Collect file list
    _fetch_paths_collect_file_list(file_paths)

    # Apply filters
    _fetch_paths_apply_filters(file_paths output_files_current)

    # Exclude list filtering, sorting, and other processing
    _fetch_paths_handle_exclusion_and_sort(output_files_current)

    # If append mode is enabled, append the output file list to the existing file list
    if (fetch_paths_APPEND)
        set(output_files_current "${${output_var}};${output_files_current}")
    endif ()

    # Remove empty strings, and set the output file list and the exclusion list
    list(FILTER output_files_current EXCLUDE REGEX "^$")  # remove empty strings
    set(${output_var} "${output_files_current}" PARENT_SCOPE)

    # Set the exclusion list
    if (DEFINED fetch_paths_EXCLUDE_LIST_VAR AND NOT "${fetch_paths_EXCLUDE_LIST_VAR}" STREQUAL "")
        set(${fetch_paths_EXCLUDE_LIST_VAR} "${${fetch_paths_EXCLUDE_LIST_VAR}}" PARENT_SCOPE)
    endif()
endfunction()
