# fetch_paths.cmake

## Introduction

`fetch_paths()` est une fonction CMake personnalisée, flexible et puissante, conçue pour rechercher des répertoires et extraire les chemins des fichiers ou sous-répertoires. Grâce à un ensemble complet d'options de filtrage basées sur des expressions régulières, vous pouvez facilement configurer le répertoire de départ, spécifier la base pour les chemins relatifs et appliquer des filtres d'inclusion et d'exclusion. Qu'il s'agisse d'une recherche récursive ou d'une simple recherche à un seul niveau, et que vous souhaitiez ajouter les nouveaux résultats aux existants ou les remplacer entièrement, `fetch_paths()` simplifie la gestion des fichiers et des répertoires lors de la compilation.

## Prototype de Fonction

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

## Explication des Paramètres

| Nom du Paramètre                           | Description                                                  |
| :----------------------------------------- | :----------------------------------------------------------- |
| `output_var`                               | Obligatoire. Cette variable stockera la liste des chemins (fichiers ou répertoires) identifiés par la recherche. |
| `RELATIVE_PATH <relative_path>`            | Définit le répertoire de base auquel les chemins de sortie seront rendus relatifs. Si non spécifié, les chemins sont relatifs à `CMAKE_CURRENT_SOURCE_DIR`. |
| `WORKING_DIRECTORY <directory>`            | Spécifie le répertoire de départ pour la recherche. Il peut être fourni sous forme de chemin relatif (par rapport à `CMAKE_CURRENT_SOURCE_DIR`). Par défaut, il s'agit de `CMAKE_CURRENT_SOURCE_DIR`. |
| `OUTPUT_FILTER_LIST <regex> ...`           | **Une liste d'expressions régulières** utilisée pour filtrer les résultats. Seuls les chemins correspondant à au moins un des motifs sont conservés. Par défaut, pour les fichiers, c'est `.+\.(c\|cpp\|cc\|cxx)$`, ou `.*` lorsque l'option `DIRECTORY` est activée. |
| `EXCLUDE_FILTER_LIST <regex> ...`          | **Une liste d'expressions régulières** définissant des motifs pour exclure des chemins. Ces filtres sont appliqués après le filtrage de sortie, éliminant les chemins correspondants. |
| `EXCLUDE_LIST_VAR <var>`                   | Spécifie le nom d'une variable pour stocker les chemins qui ne répondent pas aux critères de filtrage. Si aucun `EXCLUDE_FILTER_LIST` n'est fourni, cette variable reste vide. |
| `EXCLUDE_LIST_FILTER_LIST <regex> ...`     | **Filtrage additionnel**: applique des expressions régulières aux chemins stockés dans `EXCLUDE_LIST_VAR` et ne conserve que ceux correspondant aux motifs fournis. **Note : Ce filtre n'affecte pas la variable de sortie principale.** |
| `APPEND`                                   | Active le mode ajout. Les nouveaux chemins trouvés sont ajoutés au contenu existant de `output_var` au lieu de le remplacer. |
| `DISABLE_RECURSION`                        | Désactive la recherche récursive, de sorte que la recherche ne se fait que dans le répertoire de travail spécifié sans descendre dans les sous-répertoires. |
| `DIRECTORY`                                | Indique que la fonction doit récupérer les chemins des répertoires **plutôt que des fichiers**. Lorsque cette option est utilisée, le filtre de sortie par défaut passe automatiquement à `.*`. |

## Exemples

- Récupérer les chemins relatifs de tous les fichiers sources C/C++ dans le répertoire `CMAKE_CURRENT_SOURCE_DIR` :

  ```cmake
  fetch_paths(output_files)
  ```

- Récupérer les chemins relatifs de tous les fichiers sources C/C++ dans `CMAKE_CURRENT_SOURCE_DIR`, sans rechercher dans les sous-répertoires :

  ```cmake
  fetch_paths(output_files DISABLE_RECURSION)
  ```

- Récupérer les chemins de tous les fichiers sources C/C++ dans `CMAKE_CURRENT_SOURCE_DIR` relatifs à `CMAKE_SOURCE_DIR` :

  ```cmake
  fetch_paths(output_files RELATIVE_PATH ${CMAKE_SOURCE_DIR})
  ```

- Récupérer les chemins de tous les fichiers sources C/C++ dans `CMAKE_SOURCE_DIR` relatifs à `CMAKE_CURRENT_SOURCE_DIR` :

  ```cmake
  fetch_paths(output_files WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  ```

- Récupérer les chemins relatifs de tous les fichiers utilisés pour la compilation Qt dans `CMAKE_CURRENT_SOURCE_DIR` :

  ```cmake
  fetch_paths(output_files OUTPUT_FILTER_LIST ".+\\.ui$" ".+\\.qrc$" ".+\\.(c|cpp|cc|cxx)$" ".+\\.h$")
  ```

- Récupérer les chemins de tous les répertoires dans `CMAKE_CURRENT_SOURCE_DIR` :

  ```cmake
  fetch_paths(output_dirs DIRECTORY)
  ```

- Récupérer les chemins de tous les répertoires dans `CMAKE_CURRENT_SOURCE_DIR` relatifs au répertoire racine du système :

  ```cmake
  # Linux
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "/")
  # Windows
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "C:/")
  ```

- Récupérer les chemins relatifs de tous les fichiers et répertoires dans `CMAKE_CURRENT_SOURCE_DIR` :

  ```cmake
  fetch_paths(output OUTPUT_FILTER_LIST ".*")
  fetch_paths(output DIRECTORY APPEND)
  ```
