# fetch_paths.cmake

## 介绍

`fetch_paths()` 是一个灵活且强大的自定义 CMake 函数，专门用于搜索并提取指定目录下的文件或子目录路径。通过配置参数，您可以轻松指定搜索起始目录、调整输出路径基准以及应用正则表达式进行筛选和排除。无论是递归遍历整个目录树还是仅在指定目录中查找，`fetch_paths()` 都能满足需求，同时支持将新结果追加到已有列表或者覆盖旧数据，从而简化项目构建中对文件和目录管理的操作。

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

## 参数说明

| 参数名称                                | 描述                                                         |
| :------------------------------------- | :----------------------------------------------------------- |
| `output_var`                           | 必选参数，用于存放搜索得到的路径列表（文件或目录）。                |
| `RELATIVE_PATH <relative_path>`        | 指定输出路径应采用的相对基准。启用后，所有结果都将转换为相对于该路径的形式（默认基准为 `CMAKE_CURRENT_SOURCE_DIR`）。 |
| `WORKING_DIRECTORY <directory>`        | 设置搜索的起始目录。支持相对路径（相对于 `CMAKE_CURRENT_SOURCE_DIR`），未指定时默认为 `CMAKE_CURRENT_SOURCE_DIR`。 |
| `OUTPUT_FILTER_LIST <regex> ...`       | 使用**一组正则表达式**筛选输出结果，只有匹配其中至少一个模式的路径才会被保留。默认值针对文件搜索为 `.+\.(c|cpp|cc|cxx)$`，若同时设置 DIRECTORY 则默认为 `.*`。 |
| `EXCLUDE_FILTER_LIST <regex> ...`      | 定义**一组正则表达式**，用于在 `OUTPUT_FILTER_LIST` 筛选后进一步排除指定路径。 |
| `EXCLUDE_LIST_VAR <var>`               | 指定一个变量名，用于保存那些未通过（被排除的）路径列表。如果没有配置 `EXCLUDE_FILTER_LIST`，则此变量始终为空。 |
| `EXCLUDE_LIST_FILTER_LIST <regex> ...` | 对存放在 `EXCLUDE_LIST_VAR` 中的路径进行次级过滤，只有匹配这些正则表达式的路径会被保留。**注意：此过滤只影响排除列表，不改变输出变量（`output_var`）的内容。** |
| `APPEND`                               | 启用追加模式时，新获取的结果将添加到 `output_var` 已有的列表中；若不使用该选项，则新结果会覆盖原有内容。 |
| `DISABLE_RECURSION`                    | 使用此选项可禁用递归搜索，仅在指定的工作目录内查找，不遍历子目录。 |
| `DIRECTORY`                            | 当设置此选项时，指定目标为目录而**非文件**，且默认的**输出过滤规则**会相应调整为 ".*"。 |

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