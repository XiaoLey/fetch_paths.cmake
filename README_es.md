# fetch_paths.cmake

## Introducción

`fetch_paths()` es una función personalizada de CMake, flexible y potente, diseñada para buscar directorios y extraer rutas de archivos o subdirectorios. Con un conjunto completo de opciones de filtrado basadas en expresiones regulares, puedes configurar fácilmente el directorio de inicio, especificar la referencia para rutas relativas y aplicar filtros de inclusión y exclusión. Ya sea que necesites una búsqueda recursiva o de un único nivel, y que desees combinar los nuevos resultados con los existentes o reemplazarlos por completo, `fetch_paths()` simplifica la gestión de archivos y directorios durante el proceso de compilación.

## Prototipo de Función

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

## Explicación de Parámetros

| Nombre del Parámetro                         | Descripción                                                  |
| :------------------------------------------- | :----------------------------------------------------------- |
| `output_var`                                 | Obligatorio. Variable que almacenará la lista de rutas (archivos o directorios) encontradas. |
| `RELATIVE_PATH <relative_path>`              | Define el directorio base al que las rutas se harán relativas. Si no se especifica, se usa `CMAKE_CURRENT_SOURCE_DIR`. |
| `WORKING_DIRECTORY <directory>`              | Especifica el directorio donde inicia la búsqueda. Se puede proporcionar como ruta relativa (basada en `CMAKE_CURRENT_SOURCE_DIR`). Por defecto es `CMAKE_CURRENT_SOURCE_DIR`. |
| `OUTPUT_FILTER_LIST <regex> ...`             | **Una lista de expresiones regulares** que se utiliza para filtrar los resultados. Solo se conservan las rutas que coincidan con al menos uno de estos patrones. Por defecto, se establece en `.+\.(c\|cpp\|cc\|cxx)$` para archivos o `.*` si se habilita la opción `DIRECTORY`. |
| `EXCLUDE_FILTER_LIST <regex> ...`            | **Una lista de expresiones regulares** que define patrones para excluir rutas. Se aplican después de los filtros de salida, eliminando aquellas que coincidan. |
| `EXCLUDE_LIST_VAR <var>`                     | Especifica el nombre de una variable donde se almacenen las rutas que no cumplan los criterios de filtrado. Si no se proporciona `EXCLUDE_FILTER_LIST`, esta variable permanece vacía. |
| `EXCLUDE_LIST_FILTER_LIST <regex> ...`       | **Filtrado adicional**: aplica expresiones regulares a las rutas en `EXCLUDE_LIST_VAR`, conservándose solo las que coincidan. (Nota: este filtro no afecta la variable de salida principal). |
| `APPEND`                                     | Habilita el modo de adición. Las rutas encontradas se añaden al contenido existente de `output_var` en lugar de reemplazarlo. |
| `DISABLE_RECURSION`                          | Desactiva la búsqueda recursiva, limitando la búsqueda al directorio de trabajo especificado sin descender a subdirectorios. |
| `DIRECTORY`                                  | Indica que la función debe devolver rutas de directorios **en lugar de archivos**. Cuando se usa, el filtro de salida por defecto cambia a `.*`. |

## Ejemplos

- Recuperar las rutas relativas de todos los archivos fuente C/C++ en el directorio `CMAKE_CURRENT_SOURCE_DIR`:

  ```cmake
  fetch_paths(output_files)
  ```

- Recuperar las rutas relativas de todos los archivos fuente C/C++ en `CMAKE_CURRENT_SOURCE_DIR` sin buscar en subdirectorios:

  ```cmake
  fetch_paths(output_files DISABLE_RECURSION)
  ```

- Recuperar las rutas de todos los archivos fuente C/C++ en `CMAKE_CURRENT_SOURCE_DIR` relativas a `CMAKE_SOURCE_DIR`:

  ```cmake
  fetch_paths(output_files RELATIVE_PATH ${CMAKE_SOURCE_DIR})
  ```

- Recuperar las rutas de todos los archivos fuente C/C++ en `CMAKE_SOURCE_DIR` relativas a `CMAKE_CURRENT_SOURCE_DIR`:

  ```cmake
  fetch_paths(output_files WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  ```

- Recuperar las rutas relativas de todos los archivos involucrados en la compilación con Qt en `CMAKE_CURRENT_SOURCE_DIR`:

  ```cmake
  fetch_paths(output_files OUTPUT_FILTER_LIST ".+\\.ui$" ".+\\.qrc$" ".+\\.(c|cpp|cc|cxx)$" ".+\\.h$")
  ```

- Recuperar las rutas de todos los directorios en `CMAKE_CURRENT_SOURCE_DIR`:

  ```cmake
  fetch_paths(output_dirs DIRECTORY)
  ```

- Recuperar las rutas de todos los directorios en `CMAKE_CURRENT_SOURCE_DIR` relativas al directorio raíz del sistema:

  ```cmake
  # Linux
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "/")
  # Windows
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "C:/")
  ```

- Recuperar las rutas relativas de todos los archivos y directorios en `CMAKE_CURRENT_SOURCE_DIR`:

  ```cmake
  fetch_paths(output OUTPUT_FILTER_LIST ".*")
  fetch_paths(output DIRECTORY APPEND)
  ```
