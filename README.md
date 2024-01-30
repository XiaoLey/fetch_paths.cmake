# fetch_paths.cmake

[[🇨🇳 中文]](README_zh.md)

`fetch_paths` is a CMake function designed to retrieve a list of file or directory paths, offering a wide range of filtering and sorting options. It allows the configuration to fetch either file paths or directory paths and enables users to specify parameters such as relative paths, working directories, output filter lists, and exclude filter lists. The function supports both recursive and non-recursive searching and provides the option to append results to an existing list or overwrite it.

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

## Parameters

| Parameter Name                         | Description                                                  |
| :------------------------------------- | :----------------------------------------------------------- |
| `output_var`                           | The output list variable.                                    |
| `RELATIVE_PATH <relative_path>`        | The relative path for output. If a relative path is provided, it's relative to `CMAKE_CURRENT_SOURCE_DIR`. |
| `WORKING_DIRECTORY <directory>`        | The working directory for output. If a relative path is provided, it's relative to `CMAKE_CURRENT_SOURCE_DIR`. |
| `OUTPUT_FILTER_LIST <regex> ...`       | The output filter list, matching paths using regular expressions. |
| `EXCLUDE_FILTER_LIST <regex> ...`      | The exclude filter list, matching paths using regular expressions. **It excludes paths on top of the `OUTPUT_FILTER_LIST`.** |
| `EXCLUDE_LIST_VAR <var>`               | The exclude list variable. Paths that do not meet the filter criteria are saved to this variable. If `EXCLUDE_FILTER_LIST` is not defined, then the variable is always empty. |
| `EXCLUDE_LIST_FILTER_LIST <regex> ...` | The exclude list filter list, matching paths using regular expressions. In the `EXCLUDE_LIST_VAR` list, paths that meet this filter list's criteria are retained, and the rest are removed. **This filter only affects the `EXCLUDE_LIST_VAR`, not the `output_var`.** |
| `APPEND`                               | Append mode. If set, the output list is appended to the existing output list; otherwise, it overrides. |
| `DISABLE_RECURSION`                    | Disable recursion. If set, only files or directories in the specified working directory are retrieved (depending on the context), without recursing into subdirectories. |
| `DIRECTORY`                            | Fetch directories instead of files.                          |


## Default Values

- If `RELATIVE_PATH` and `WORKING_DIRECTORY` are not specified or are empty, the default is `CMAKE_CURRENT_SOURCE_DIR`.
- The default `OUTPUT_FILTER_LIST` is `[".+\.(c|cpp|cc|cxx)$"]`, if `DIRECTORY` is set, then it is `[".*"]`.
- The default `EXCLUDE_FILTER_LIST` is undefined.
- The default `EXCLUDE_LIST_FILTER_LIST` is `[".*"]`.
- `DISABLE_RECURSION`, `APPEND` are not set by default.

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