# Levenshtein UDF for MySQL

This repository provides a User Defined Function (UDF) written in C for MySQL/MariaDB that allows you to calculate the Levenshtein distance between two strings directly via SQL queries. It is an ideal tool for implementing fuzzy comparisons, advanced text search, deduplication, and data cleaning within the database, without relying on external application logic.

## What is the Levenshtein distance?

The Levenshtein distance measures the minimum number of operations (insertions, deletions, substitutions) required to transform one string into another. It is widely used in text search, autocorrection, deduplication, and fuzzy matching.

> **Note:** The implementation supports both case-insensitive comparison (default) and case-sensitive comparison via an optional third argument.

## Features

- Implementation in C as a UDF for MySQL/MariaDB.
- Support for case-insensitive (default) and case-sensitive comparison.
- Handles `NULL` input and empty strings.
- Automated build and test scripts.
- Usage examples and SQL unit tests.

## Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/BotrugnoMarco/Levenshtein-MySQL-UDF-Enhanced.git
   cd levenshtein
   ```

2. **Configure environment variables:**
   Edit the `.env` file with your MySQL environment parameters.

3. **Compile and register the function:**

   ```bash
   cd scripts
   ./build.sh
   ```

   The `build.sh` script automates the following steps:

   - Compiles the C source code (`levenshtein.c`) into a shared library (`levenshtein.so`) ready for MySQL/MariaDB.
   - (If using Docker) Builds the Docker image for MySQL, copying the compiled `.so` into the plugin directory.
   - Stops and restarts the MySQL Docker container specified by the `CONTAINER_NAME` variable.
   - Waits for the MySQL service to be ready.
   - Connects to the specified MySQL database and registers the UDF `levenshtein`, overwriting any previous version.
   - Shows status and error messages for each step.

   This script is designed to simplify the entire build, deployment, and registration process, ensuring the UDF is ready to use with minimal manual intervention.

4. **Copy the compiled `.so` to the MySQL plugin directory:**

   If you are using Docker, this is handled automatically by the Dockerfile with:

   ```dockerfile
   COPY ./levenshtein/levenshtein.so /usr/lib/mysql/plugin/
   ```

   If you are installing manually, copy the `levenshtein.so` file to your MySQL plugin directory (usually `/usr/lib/mysql/plugin/`).

## Usage

### Syntax

```sql
SELECT levenshtein(str1, str2 [, ignore_case]);
```

- `str1`, `str2`: strings to compare.
- `ignore_case` (optional): `"1"`/`"true"` (default, case-insensitive), `"0"`/`"false"` (case-sensitive).

### Examples

```sql
SELECT levenshtein('kitten', 'sitting');           -- Output: 3
SELECT levenshtein('Home', 'home');                -- Output: 0 (default case-insensitive)
SELECT levenshtein('Home', 'home', '0');           -- Output: 1 (case-sensitive)
SELECT levenshtein('home', 'Home', 'false');       -- Output: 4 (case-sensitive)
SELECT levenshtein('abc', NULL);                   -- Output: NULL
```

### Running the tests

To run the SQL unit tests, make sure the environment variables are set (for example, exported in the terminal or present in the `.env` file). Run:

```bash
mysql -u "$MYSQL_USER" -p -h "$MYSQL_HOST" -P "$MYSQL_PORT" "$MYSQL_DB" < tests/test_levenshtein.sql
```

> **Note:** If you run the command directly from the shell, replace the variables with actual values, for example:
>
> ```bash
> mysql -u root -p -h 127.0.0.1 -P 3306 dev < tests/test_levenshtein.sql
> ```

### Running the benchmarks

A benchmark script is provided to measure the performance of the `levenshtein` UDF with different string lengths and scenarios.

The benchmark script now shows the execution time for each individual query directly in the output.

To run the benchmarks and see the time for each query:

```bash
mysql -u "$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" -h "$MYSQL_HOST" -P "$MYSQL_PORT" "$MYSQL_DB" < tests/bench_levenshtein.sql
```

or

```bash
mysql -u root -p -h 127.0.0.1 -P 3306 dev < tests/bench_levenshtein.sql
```

Each query's execution time will be displayed in the result set.

## Environment variables

Create a `.env` file in the project root with the following variables:

- `MYSQL_USER`: MySQL user with privileges to register UDFs and run tests.
- `MYSQL_PASSWORD`: Password for the MySQL user.
- `MYSQL_HOST`: Hostname or IP address of the MySQL server (e.g., `127.0.0.1`).
- `MYSQL_PORT`: Port number for the MySQL server (e.g., `3306` or custom).
- `MYSQL_DB`: Name of the database where the UDF will be registered and tested.
- `IMAGE_NAME`: Name of the Docker image to build (e.g., `my-mysql-udf`).
- `TAG`: Tag for the Docker image (e.g., `latest`).
- `CONTAINER_NAME`: Name of the Docker container to stop/start (e.g., `mysql`).

Example `.env` file:

```env
MYSQL_USER=root
MYSQL_PASSWORD=yourpassword
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_DB=dev
IMAGE_NAME=my-mysql-udf
TAG=latest
CONTAINER_NAME=mysql
```

## Technical details

- **Algorithm:** Classic Levenshtein distance.
- **Input:** Two strings, optionally a flag for case sensitivity.
- **Output:** Integer (distance), or `NULL` if one of the inputs is `NULL`.
- **Performance:** Suitable for strings of moderate length.

## Main files

- `src/levenshtein.c` — UDF source code.
- `scripts/build.sh` — Build, deploy, and function registration script.
- `tests/test_levenshtein.sql` — SQL unit tests.
- `tests/bench_levenshtein.sql` — SQL benchmarks for performance testing (shows per-query timing).
- `.env` — Environment configuration.

## Contributing

Contributions and feedback are welcome! Open an issue or a pull request on GitHub.

## License

Distributed under the MIT license. See the [LICENSE](./LICENSE) file.
