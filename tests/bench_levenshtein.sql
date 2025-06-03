SET PROFILING = 1;

-- Helper to display clear results
SELECT '=== LEVENSHTEIN BENCHMARK START ===' AS Info;
-- Short strings, repeated 10000 times
SELECT 'Short strings (10000x)' AS Test,
    BENCHMARK(10000, levenshtein('kitten', 'sitting')) AS DummyResult;
-- Medium strings, repeated 1000 times
SELECT 'Medium strings (1000x)' AS Test,
    BENCHMARK(
        1000,
        levenshtein(REPEAT('abc', 10), REPEAT('abd', 10))
    ) AS DummyResult;
-- Long strings, repeated 100 times
SELECT 'Long strings (100x)' AS Test,
    BENCHMARK(
        100,
        levenshtein(REPEAT('a', 100), REPEAT('b', 100))
    ) AS DummyResult;
-- Very long strings, repeated 10 times
SELECT 'Very long strings (10x)' AS Test,
    BENCHMARK(
        10,
        levenshtein(REPEAT('x', 500), REPEAT('y', 500))
    ) AS DummyResult;
-- Case-sensitive vs case-insensitive
SELECT 'Case-insensitive (1000x)' AS Test,
    BENCHMARK(1000, levenshtein('Home', 'home', '1')) AS DummyResult;
SELECT 'Case-sensitive (1000x)' AS Test,
    BENCHMARK(1000, levenshtein('Home', 'home', '0')) AS DummyResult;
-- NULL handling (should be fast)
SELECT 'NULL input (10000x)' AS Test,
    BENCHMARK(10000, levenshtein(NULL, 'abc')) AS DummyResult;
SELECT '=== END OF BENCHMARK ===' AS Info;
SHOW PROFILES;