cmake_minimum_required(VERSION 3.20)

project(fetch_paths_cmake VERSION 0.1.0 LANGUAGES)

option(FETCH_PATHS_BUILD_TESTS "Build tests" OFF)

set(FETCH_PATHS_CMAKE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

if(FETCH_PATHS_BUILD_TESTS)
    add_subdirectory(tests)
endif()