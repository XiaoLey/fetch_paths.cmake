cmake_minimum_required(VERSION 3.10)

project(fetch_paths_cmake VERSION 0.1.6 LANGUAGES)

set(FETCH_PATHS_CMAKE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake" CACHE PATH "Path to cmake directory")

if("${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}")
    add_subdirectory(tests)
endif()
