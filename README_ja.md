# fetch_paths.cmake

## はじめに

`fetch_paths()` は柔軟かつ強力なカスタム CMake 関数で、ディレクトリ内のファイルやサブディレクトリのパスを検索・抽出するために設計されています。正規表現に基づく豊富なフィルタリングオプションを使用することで、検索開始ディレクトリの設定、相対パスの基準の指定、ならびにインクルードおよび除外フィルタの適用が容易に行えます。再帰的な検索や単一レベルの検索、新しい結果を既存のリストに追加するモード、または既存のものを置き換えるモードなど、プロジェクトのビルドプロセスにおけるファイルとディレクトリの管理を簡素化します。

## 関数プロトタイプ

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

## パラメーターの説明

| パラメーター                      | 説明                                                          |
| :-------------------------------- | :------------------------------------------------------------ |
| `output_var`                     | 必須パラメーター。検索によって検出されたパス（ファイルまたはディレクトリ）のリストが格納されます。 |
| `RELATIVE_PATH <relative_path>`  | 出力パスが相対化される基準となるディレクトリを指定します。指定しなければ、`CMAKE_CURRENT_SOURCE_DIR` が使用されます。 |
| `WORKING_DIRECTORY <directory>`  | 検索の開始ディレクトリを指定します。`CMAKE_CURRENT_SOURCE_DIR` を基準とする相対パスも使用可能です（省略時は `CMAKE_CURRENT_SOURCE_DIR` がデフォルト）。 |
| `OUTPUT_FILTER_LIST <regex> ...` | **正規表現のリスト**を使用して出力結果をフィルタリングします。これらのパターンのうち少なくとも1つに一致するパスのみが保持されます。通常、ファイル検索の場合は `.+\.(c\|cpp\|cc\|cxx)$`、DIRECTORY オプションが有効な場合は `.*` がデフォルトとなります。 |
| `EXCLUDE_FILTER_LIST <regex> ...` | **正規表現のリスト**を定義し、出力フィルタ後に除外するパスを指定します。 |
| `EXCLUDE_LIST_VAR <var>`         | 除外されたパスリスト（フィルタリングに失敗したパス）を格納するための変数名を指定します。EXCLUDE_FILTER_LIST が設定されていなければ、常に空になります。 |
| `EXCLUDE_LIST_FILTER_LIST <regex> ...` | **追加フィルタ**を適用し、`EXCLUDE_LIST_VAR` 内のパスから指定の正規表現に一致するものだけを残します。（このフィルタは出力変数には影響しません。） |
| `APPEND`                         | 追加モードを有効にすると、検索で得られた新しいパスが既存の output_var に追加されます。 |
| `DISABLE_RECURSION`              | 再帰的な検索を無効にし、指定された作業ディレクトリ内のみで検索を行います。 |
| `DIRECTORY`                      | 関数に対し、ファイルではなくディレクトリのパスを返すよう指定します。この場合、デフォルトの出力フィルタが自動的に `.*` に変更されます。 |

## 例

- `CMAKE_CURRENT_SOURCE_DIR` 内の全ての C/C++ ソースファイルの相対パスを取得する:

  ```cmake
  fetch_paths(output_files)
  ```

- `CMAKE_CURRENT_SOURCE_DIR` 内の全ての C/C++ ソースファイルの相対パスを取得するが、サブディレクトリは検索しない場合:

  ```cmake
  fetch_paths(output_files DISABLE_RECURSION)
  ```

- `CMAKE_CURRENT_SOURCE_DIR` 内の全ての C/C++ ソースファイルのパスを、`CMAKE_SOURCE_DIR` を基準にして取得する:

  ```cmake
  fetch_paths(output_files RELATIVE_PATH ${CMAKE_SOURCE_DIR})
  ```

- `CMAKE_SOURCE_DIR` 内の全ての C/C++ ソースファイルのパスを、`CMAKE_CURRENT_SOURCE_DIR` を基準にして取得する:

  ```cmake
  fetch_paths(output_files WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  ```

- Qt のコンパイルに使用されるファイルの相対パスを `CMAKE_CURRENT_SOURCE_DIR` から取得する:

  ```cmake
  fetch_paths(output_files OUTPUT_FILTER_LIST ".+\\.ui$" ".+\\.qrc$" ".+\\.(c|cpp|cc|cxx)$" ".+\\.h$")
  ```

- `CMAKE_CURRENT_SOURCE_DIR` 内の全てのディレクトリパスを取得する:

  ```cmake
  fetch_paths(output_dirs DIRECTORY)
  ```

- システムのルートディレクトリを基準とした、`CMAKE_CURRENT_SOURCE_DIR` 内の全ディレクトリパスを取得する:

  ```cmake
  # Linux
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "/")
  # Windows
  fetch_paths(output_dirs DIRECTORY RELATIVE_PATH "C:/")
  ```

- `CMAKE_SOURCE_DIR` 内の全てのファイルとディレクトリの相対パスを取得する:

  ```cmake
  fetch_paths(output OUTPUT_FILTER_LIST ".*")
  fetch_paths(output DIRECTORY APPEND)
  ```
