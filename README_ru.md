# fetch_paths.cmake

## Введение

Функция `fetch_paths()` — это гибкая и мощная пользовательская функция CMake, предназначенная для поиска директорий и извлечения путей к файлам или подкаталогам. С использованием набора фильтров на основе регулярных выражений вы можете легко указать начальную директорию, задать базу для относительных путей, а также применить фильтры включения и исключения. Независимо от того, требуется ли рекурсивный обход или поиск только в одном каталоге, а также объединение новых результатов с существующими или полная их замена — `fetch_paths()` упрощает управление файлами и каталогами в процессе сборки.

## Синтаксис функции

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

## Параметры

| Параметр                              | Описание                                                   |
| :------------------------------------ | :--------------------------------------------------------- |
| `output_var`                          | Обязательный параметр, содержащий список найденных путей (файлов или директорий). |
| `RELATIVE_PATH <relative_path>`       | Определяет базовую директорию, относительно которой будут приведены пути. Если не указан, используется `CMAKE_CURRENT_SOURCE_DIR`. |
| `WORKING_DIRECTORY <directory>`       | Задает директорию, с которой начинается поиск. Может быть задан относительно `CMAKE_CURRENT_SOURCE_DIR`. По умолчанию — `CMAKE_CURRENT_SOURCE_DIR`. |
| `OUTPUT_FILTER_LIST <regex> ...`      | **Список регулярных выражений** для фильтрации результатов. Будут сохранены только пути, соответствующие хотя бы одному из шаблонов. По умолчанию для файлов используется `.+\.(c\|cpp\|cc\|cxx)$`, а при использовании `DIRECTORY` — `.*`. |
| `EXCLUDE_FILTER_LIST <regex> ...`     | **Список регулярных выражений** для исключения путей после первичной фильтрации. |
| `EXCLUDE_LIST_VAR <var>`              | Указывает имя переменной для хранения путей, не удовлетворяющих фильтрам. Если `EXCLUDE_FILTER_LIST` не задан, переменная остаётся пустой. |
| `EXCLUDE_LIST_FILTER_LIST <regex> ...`| **Список дополнительных регулярных выражений** для фильтрации путей в `EXCLUDE_LIST_VAR`. **Обратите внимание: этот фильтр не влияет на основной список путей.** |
| `APPEND`                              | Режим добавления. Новые пути дописываются к уже существующим в `output_var`. |
| `DISABLE_RECURSION`                   | Отключает рекурсивный поиск — поиск производится только в указанном каталоге без обхода подкаталогов. |
| `DIRECTORY`                           | Указывает, что возвращаются пути к директориям, а не к файлам. При этом фильтр по умолчанию меняется на `.*`. |

## Примеры

- Получить относительные пути всех C/C++ исходных файлов в директории `CMAKE_CURRENT_SOURCE_DIR`:

  ```cmake
  fetch_paths(output_files)
  ```

- Получить относительные пути всех C/C++ исходных файлов в `CMAKE_CURRENT_SOURCE_DIR`, без рекурсивного обхода:

  ```cmake
  fetch_paths(output_files DISABLE_RECURSION)
  ```

- Получить пути всех C/C++ исходных файлов в `CMAKE_CURRENT_SOURCE_DIR` относительно `CMAKE_SOURCE_DIR`:

  ```cmake
  fetch_paths(output_files RELATIVE_PATH ${CMAKE_SOURCE_DIR})
  ```

- Получить пути всех C/C++ исходных файлов в `CMAKE_SOURCE_DIR` относительно `CMAKE_CURRENT_SOURCE_DIR`:

  ```cmake
  fetch_paths(output_files WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  ```

- Получить относительные пути всех файлов, участвующих в компиляции Qt, из `CMAKE_CURRENT_SOURCE_DIR`:

  ```cmake
  fetch_paths(output_files OUTPUT_FILTER_LIST ".+\\.ui$" ".+\\.qrc$" ".+\\.(c|cpp|cc|cxx)$" ".+\\.h$")
  ```

- Получить пути всех директорий в `CMAKE_CURRENT_SOURCE_DIR`:

  ```cmake
  fetch_paths(output_dirs DIRECTORY)
  ```

- Получить пути всех директорий в `CMAKE_CURRENT_SOURCE_DIR` относительно корневой директории системы:

  ```cmake
  # Linux
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "/")
  # Windows
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "C:/")
  ```

- Получить относительные пути всех файлов и директорий в `CMAKE_SOURCE_DIR`:

  ```cmake
  fetch_paths(output OUTPUT_FILTER_LIST ".*")
  fetch_paths(output DIRECTORY APPEND)
  ```
