# Levenshtein UDF for MySQL

This repository provides a User Defined Function (UDF) written in C for MySQL/MariaDB that allows you to calculate the Levenshtein distance between two strings directly via SQL queries. It is an ideal tool for implementing fuzzy comparisons, advanced text search, deduplication, and data cleaning within the database, without relying on external application logic.

## What is the Levenshtein distance?

The Levenshtein distance measures the minimum number of operations (insertions, deletions, substitutions) required to transform one string into another. It is widely used in text search, autocorrection, deduplication, and fuzzy matching.

> **Note:** The implementation supports both case-insensitive comparison (default) and case-sensitive comparison via an optional third argument.

## Features

- Implementation in C as a UDF for MySQL/MariaDB.
- Support for case-insensitive (default) and case-sensitive comparison.
- Handles `NULL` input and empty strings.
- Usage examples and SQL unit tests.

## Installation and Build

The recommended way is to **clone the repository directly inside the Dockerfile** during the build process.

If you want to run the tests or benchmarks inside the container, **do not remove the repository folder after compilation**.  
You can comment out or remove the cleanup line in the Dockerfile:

```dockerfile
# Install MySQL development libraries and git
RUN apt-get update && apt-get install -y gcc default-libmysqlclient-dev git

# Clone the repository inside the container
RUN git clone https://github.com/BotrugnoMarco/Levenshtein-MySQL-UDF-Enhanced.git /levenshtein

# Compile the shared library
RUN gcc -Wall -fPIC -I/usr/include/mysql -shared -o /usr/lib/mysql/plugin/levenshtein.so /levenshtein/src/levenshtein.c -lm

# If you want to save space and do NOT need tests, you can remove the source folder:
# RUN rm -rf /levenshtein
```

**If you want to run the SQL tests or benchmarks inside the container, keep the `/levenshtein` folder.**  
You can then run the test scripts from that path.

**Registering the function in MySQL:**
After starting the container, you can register the function with:

```sql
DROP FUNCTION IF EXISTS levenshtein
CREATE FUNCTION levenshtein RETURNS INTEGER SONAME 'levenshtein.so';
```

## Usage

### Syntax

```sql
SELECT levenshtein(str1, str2, [ignore_case]);
```

- `str1`, `str2`: strings to compare.
- `ignore_case` (optional): `1`/`true` (default, case-insensitive), `"0"`/`"false"` (case-sensitive).

### Examples

```sql
SELECT levenshtein('kitten', 'sitting');           -- Output: 3
SELECT levenshtein('Home', 'home');                -- Output: 0 (default case-insensitive)
SELECT levenshtein('Home', 'home', '0');           -- Output: 1 (case-sensitive)
SELECT levenshtein('home', 'Home', false);       -- Output: 4 (case-sensitive)
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

## Technical details

- **Algorithm:** Classic Levenshtein distance.
- **Input:** Two strings, optionally a flag for case sensitivity.
- **Output:** Integer (distance), or `NULL` if one of the inputs is `NULL`.
- **Performance:** Suitable for strings of moderate length.

## Main files

- `src/levenshtein.c` — UDF source code.
- `tests/test_levenshtein.sql` — SQL unit tests.
- `tests/bench_levenshtein.sql` — SQL benchmarks for performance testing (shows per-query timing).

## Contributing

Contributions and feedback are welcome! Open an issue or a pull request on GitHub.

## License

Distributed under the MIT license. See the [LICENSE](./LICENSE) file.
