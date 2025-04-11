# fetch_paths.cmake

[[🇨🇳 中文]](README_zh.md)

## Introduction

**A minimal yet powerful CMake utility for smart file & directory path handling.**

Tired of manually managing paths in your CMake projects? `fetch_paths.cmake` provides a **lightweight, flexible solution** to:

- 🔍 Dynamically retrieve file/directory paths
- ⚙️ Support recursive search and regex filtering
- 📏 Generate paths relative to specified directory

```cmake
include(fetch_paths.cmake)
fetch_paths(output_files OUTPUT_FILTER_LIST ".+\\.(c|cpp|h|hpp|qrc|ui)$")  # That's it!
add_executable(qt_pro ${output_files})
```

**Ideal for:**

✔ Modern CMake projects

✔ Projects with dynamic file structures

✔ Replacing messy `file(GLOB)` or manual path lists

## Function Prototype

```cmake
fetch_paths(<output_var>
            [RELATIVE_PATH <relative_path>]
            [WORKING_DIRECTORY <directory>]
            [OUTPUT_FILTER_LIST <regex> ...]
            [EXCLUDE_FILTER_LIST <regex> ...]
            [EXCLUDE_LIST_VAR <var>]
            [EXCLUDE_LIST_FILTER_LIST <regex> ...]
            [APPEND]
            [DISABLE_RECURSION]
            [DIRECTORY])
```

## Parameter Explanation

| Parameter Name                         | Description                                                  |
| :------------------------------------- | :----------------------------------------------------------- |
| `output_var`                           | Mandatory. This variable will store the list of paths (files or directories) identified by the search. |
| `RELATIVE_PATH <relative_path>`        | Defines the base directory to which the output paths will be made relative. If not specified, paths default to being relative to `CMAKE_CURRENT_SOURCE_DIR`. |
| `WORKING_DIRECTORY <directory>`        | Specifies the directory where the search begins. This can be provided as a relative path (based on `CMAKE_CURRENT_SOURCE_DIR`). If omitted, it defaults to `CMAKE_CURRENT_SOURCE_DIR`. |
| `OUTPUT_FILTER_LIST <regex> ...`       | **A list of regular expressions** used to filter the output results. Only paths matching at least one of these patterns are kept. By default, this is set to `.+\.(c\|cpp\|cc\|cxx)$` for files, or `.*` when the `DIRECTORY` option is enabled. |
| `EXCLUDE_FILTER_LIST <regex> ...`      | **A list of regular expressions** defining patterns for paths to exclude. These filters are applied after the output filters, removing any paths that match the specified patterns. |
| `EXCLUDE_LIST_VAR <var>`               | Specifies a variable name where paths that do not meet the filter criteria are stored. If no `EXCLUDE_FILTER_LIST` is provided, this variable remains empty. |
| `EXCLUDE_LIST_FILTER_LIST <regex> ...` | Applies additional filtering to the paths collected in `EXCLUDE_LIST_VAR`, only retaining those that match the provided regular expressions. **Note that this filter does not affect the main output variable.** |
| `APPEND`                               | Enables append mode. When set, newly found paths will be added to the existing content of `output_var` rather than replacing it. |
| `DISABLE_RECURSION`                    | Disables recursive search, so the function will only search within the specified working directory without descending into subdirectories. |
| `DIRECTORY`                            | Indicates that the function should retrieve directory paths **instead of file paths**. When used, the default **output filter** automatically changes to `.*`. |

## Examples

- Retrieve the relative paths of all C/C++ source files in the `CMAKE_CURRENT_SOURCE_DIR` directory.

  ```cmake
  fetch_paths(output_files)
  ```

- Retrieve the relative paths of all C/C++ source files in the `CMAKE_CURRENT_SOURCE_DIR` directory, but do not search subdirectories.

  ```cmake
  fetch_paths(output_files DISABLE_RECURSION)
  ```

- Retrieve the paths of all C/C++ source files in the `CMAKE_CURRENT_SOURCE_DIR` directory relative to `CMAKE_SOURCE_DIR`.

  ```cmake
  fetch_paths(output_files RELATIVE_PATH ${CMAKE_SOURCE_DIR})
  ```

- Retrieve the paths of all C/C++ source files in the `CMAKE_SOURCE_DIR` directory relative to `CMAKE_CURRENT_SOURCE_DIR`.

  ```cmake
  fetch_paths(output_files WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  ```

- Retrieve the relative paths of all files involved in Qt compilation in the `CMAKE_CURRENT_SOURCE_DIR` directory.

  ```cmake
  fetch_paths(output_files OUTPUT_FILTER_LIST ".+\\.ui$" ".+\\.qrc$" ".+\\.(c|cpp|cc|cxx)$" ".+\\.h$")
  ```

- Retrieve all directory paths in the `CMAKE_CURRENT_SOURCE_DIR` directory.

  ```cmake
  fetch_paths(output_dirs DIRECTORY)
  ```

- Retrieve all directory paths in the `CMAKE_CURRENT_SOURCE_DIR` directory relative to the system root directory.

  ```cmake
  # Linux
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "/")
  # Windows
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "C:/")
  ```

- Retrieve the relative paths of all files and directories in the `CMAKE_CURRENT_SOURCE_DIR` directory.

  ```cmake
  fetch_paths(output OUTPUT_FILTER_LIST ".*")
  fetch_paths(output DIRECTORY APPEND)
  ```