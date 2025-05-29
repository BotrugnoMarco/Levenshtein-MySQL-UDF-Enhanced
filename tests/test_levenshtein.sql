-- Helper to display clear results
SELECT '=== LEVENSHTEIN UNIT TEST START ===' AS Info;

-- Test 1: distance between "kitten" and "sitting" = 3
SELECT 'kitten vs sitting' AS Test, levenshtein('kitten', 'sitting') AS Result, 
       IF(levenshtein('kitten', 'sitting') = 3, 'PASS', 'FAIL') AS Status;

-- Test 2: distance between "flaw" and "lawn" = 2
SELECT 'flaw vs lawn' AS Test, levenshtein('flaw', 'lawn') AS Result, 
       IF(levenshtein('flaw', 'lawn') = 2, 'PASS', 'FAIL') AS Status;

-- Test 3: distance between "gumbo" and "gambol" = 2
SELECT 'gumbo vs gambol' AS Test, levenshtein('gumbo', 'gambol') AS Result, 
       IF(levenshtein('gumbo', 'gambol') = 2, 'PASS', 'FAIL') AS Status;

-- Test 4: identical strings = 0
SELECT 'same string' AS Test, levenshtein('abc', 'abc') AS Result, 
       IF(levenshtein('abc', 'abc') = 0, 'PASS', 'FAIL') AS Status;

-- Test 5: distance between "a" and "" = 1
SELECT 'a vs empty' AS Test, levenshtein('a', '') AS Result, 
       IF(levenshtein('a', '') = 1, 'PASS', 'FAIL') AS Status;

-- Test 6: empty strings = 0
SELECT 'empty vs empty' AS Test, levenshtein('', '') AS Result, 
       IF(levenshtein('', '') = 0, 'PASS', 'FAIL') AS Status;

-- Test 7: NULL vs string → NULL
SELECT 'null vs abc' AS Test, levenshtein(NULL, 'abc') IS NULL AS Result, 
       IF(levenshtein(NULL, 'abc') IS NULL, 'PASS', 'FAIL') AS Status;

-- Test 8: string vs NULL → NULL
SELECT 'abc vs null' AS Test, levenshtein('abc', NULL) IS NULL AS Result, 
       IF(levenshtein('abc', NULL) IS NULL, 'PASS', 'FAIL') AS Status;

-- Test 9: NULL vs NULL → NULL
SELECT 'null vs null' AS Test, levenshtein(NULL, NULL) IS NULL AS Result, 
       IF(levenshtein(NULL, NULL) IS NULL, 'PASS', 'FAIL') AS Status;

-- Test 10: distance between "bar" and "baz" = 1
SELECT 'bar vs baz' AS Test, levenshtein('bar', 'baz') AS Result, 
       IF(levenshtein('bar', 'baz') = 1, 'PASS', 'FAIL') AS Status;

SELECT '=== END OF UNIT TEST LEVENSHTEIN ===' AS Info;
