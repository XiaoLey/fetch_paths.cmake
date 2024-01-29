# fetch_paths.cmake

`fetch_paths` 是一个 CMake 函数，用于检索文件或目录路径，并支持各种过滤和排序选项。它可以配置为获取文件路径或目录路径，并允许用户指定相对路径、工作目录、输出过滤列表、排除过滤列表等参数。此函数支持递归搜索和非递归搜索，也支持将结果追加到已有列表或覆盖现有列表。

## 函数原型

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

## 参数

| 参数名称                                | 描述                                                         |
| :------------------------------------- | :----------------------------------------------------------- |
| `output_var`                           | 输出文件列表变量。                                           |
| `RELATIVE_PATH <relative_path>`        | 文件的相对路径。如果提供相对路径，相对于 `CMAKE_CURRENT_SOURCE_DIR`。 |
| `WORKING_DIRECTORY <directory>`        | 工作目录。如果提供相对路径，相对于 `CMAKE_CURRENT_SOURCE_DIR`。 |
| `OUTPUT_FILTER_LIST <regex> ...`       | 输出过滤列表，使用正则表达式匹配文件的相对路径。             |
| `EXCLUDE_FILTER_LIST <regex> ...`      | 排除过滤列表，使用正则表达式匹配文件的相对路径。**其优先级高于“输出过滤列表（`OUTPUT_FILTER_LIST`）”。** |
| `EXCLUDE_LIST_VAR <var>`               | 排除列表变量。不符合过滤条件的文件路径将被保存到此变量。     |
| `EXCLUDE_LIST_FILTER_LIST <regex> ...` | 排除列表过滤列表，使用正则表达式匹配文件的相对路径。在“排除列表（`EXCLUDE_LIST_VAR`）” 列表中，符合该列表过滤条件的路径将被保留，其余的被移除。 |
| `APPEND`                               | 追加模式。如果设置，输出文件列表将追加到现有文件列表，否则覆盖。 |
| `DISABLE_RECURSION`                    | 禁用递归。如果设置，只检索指定工作目录中的文件，不递归子目录。 |
| `DIRECTORY`                            | 获取目录而非文件。                                           |

## 默认值

- `RELATIVE_PATH` 和 `WORKING_DIRECTORY` 若未指定或为空，默认为 `CMAKE_CURRENT_SOURCE_DIR`。
- `OUTPUT_FILTER_LIST` 默认为 `[".+\.(c|cpp|cc|cxx)$"]`，如果设置了 `DIRECTORY`，则为 `[".*"]`。
- `EXCLUDE_FILTER_LIST` 默认为空。
- `EXCLUDE_LIST_FILTER_LIST` 默认为 `[".*"]`。
- `DISABLE_RECURSION`, `APPEND` 默认不设置。

## 示例

- 获取 `CMAKE_CURRENT_SOURCE_DIR` 目录中所有 C/C++ 源文件的相对路径。

  ```cmake
  fetch_paths(output_files)
  ```

- 获取 `CMAKE_CURRENT_SOURCE_DIR` 目录中所有 C/C++ 源文件的相对路径，但不查找子目录。

  ```cmake
  fetch_paths(output_files DISABLE_RECURSION)
  ```

- 获取 `CMAKE_CURRENT_SOURCE_DIR` 目录中所有 C/C++ 源文件的相对于 `CMAKE_SOURCE_DIR` 的路径。

  ```cmake
  fetch_paths(output_files RELATIVE_PATH ${CMAKE_SOURCE_DIR})
  ```

- 获取 `CMAKE_SOURCE_DIR` 目录中所有 C/C++ 源文件的相对于 `CMAKE_CURRENT_SOURCE_DIR` 的路径。

  ```cmake
  fetch_paths(output_files WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  ```

- 获取 `CMAKE_CURRENT_SOURCE_DIR` 目录中所有参与 Qt 编译的文件的相对路径。

  ```cmake
  fetch_paths(output_files OUTPUT_FILTER_LIST ".+\\.ui$" ".+\\.qrc$" ".+\\.(c|cpp|cc|cxx)$" ".+\\.h$")
  ```

- 获取 `CMAKE_CURRENT_SOURCE_DIR` 目录中所有目录路径。

  ```cmake
  fetch_paths(output_dirs DIRECTORY)
  ```

- 获取 `CMAKE_CURRENT_SOURCE_DIR` 目录中所有目录的相对于系统根目录的路径。

  ```cmake
  # Linux
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "/")
  # Windows
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "C:/")
  ```

- 获取 `CMAKE_SOURCE_DIR` 目录中所有文件和目录的相对路径。

  ```cmake
  fetch_paths(output OUTPUT_FILTER_LIST ".*")
  fetch_paths(output DIRECTORY APPEND)
  ```