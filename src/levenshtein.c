#include <mysql/mysql.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>

/**
 * Levenshtein Function - UDF for MySQL
 * Compares two strings and returns the Levenshtein distance.
 * Optional third argument: case-insensitive (default) or case-sensitive.
 */
int levenshtein(UDF_INIT *initid, UDF_ARGS *args, char *is_null, char *error)
{
    // Validation of topics
    if (args->arg_count < 2 || args->arg_count > 3 ||
        args->arg_type[0] != STRING_RESULT || args->arg_type[1] != STRING_RESULT)
    {
        *error = 1;
        return -1;
    }

    const char *s1 = args->args[0];
    const char *s2 = args->args[1];

    if (!s1 || !s2)
    {
        *is_null = 1;
        return -1;
    }

    // Determines whether to ignore uppercase/lowercase
    int ignore_case = 1; // DEFAULT: case-insensitive
    if (args->arg_count == 3 && args->args[2])
    {
        int is_false = 0;
        // Check for string "0" or "false" (case-insensitive)
        if (args->arg_type[2] == STRING_RESULT)
        {
            const char *flag = args->args[2];
            if ((strcmp(flag, "0") == 0) ||
                (strcasecmp(flag, "false") == 0))
            {
                is_false = 1;
            }
        }
        // Check for integer 0 (MySQL boolean false or numeric 0)
        if (args->arg_type[2] == INT_RESULT)
        {
            long long val = *((long long *)args->args[2]);
            if (val == 0)
            {
                is_false = 1;
            }
        }
        // Check for empty string (MySQL boolean false as empty string)
        if (args->lengths[2] == 0)
        {
            is_false = 1;
        }
        if (is_false)
        {
            ignore_case = 0;
        }
    }

    // Copy strings for normalization if necessary
    size_t len1 = strlen(s1);
    size_t len2 = strlen(s2);

    char *str1 = (char *)malloc(len1 + 1);
    char *str2 = (char *)malloc(len2 + 1);
    if (!str1 || !str2)
    {
        *error = 1;
        return -1;
    }

    strcpy(str1, s1);
    strcpy(str2, s2);

    if (ignore_case)
    {
        for (size_t i = 0; i < len1; i++)
            str1[i] = tolower(str1[i]);
        for (size_t i = 0; i < len2; i++)
            str2[i] = tolower(str2[i]);
    }

    // Matrix allocation
    int **d = (int **)malloc((len1 + 1) * sizeof(int *));
    if (!d)
    {
        free(str1);
        free(str2);
        *error = 1;
        return -1;
    }

    for (size_t i = 0; i <= len1; i++)
    {
        d[i] = (int *)malloc((len2 + 1) * sizeof(int));
        if (!d[i])
        {
            for (size_t k = 0; k < i; k++)
                free(d[k]);
            free(d);
            free(str1);
            free(str2);
            *error = 1;
            return -1;
        }
    }

    // Initialize matrix edges
    for (size_t i = 0; i <= len1; i++)
        d[i][0] = i;
    for (size_t j = 0; j <= len2; j++)
        d[0][j] = j;

    // Distance calculation
    for (size_t i = 1; i <= len1; i++)
    {
        for (size_t j = 1; j <= len2; j++)
        {
            int cost = (str1[i - 1] == str2[j - 1]) ? 0 : 1;
            int deletion = d[i - 1][j] + 1;
            int insertion = d[i][j - 1] + 1;
            int substitution = d[i - 1][j - 1] + cost;
            d[i][j] = fmin(fmin(deletion, insertion), substitution);
        }
    }

    int result = d[len1][len2];

    // Cleanup
    for (size_t i = 0; i <= len1; i++)
        free(d[i]);
    free(d);
    free(str1);
    free(str2);

    return result;
}

/**
 * UDF Initialization
 */
char levenshtein_init(UDF_INIT *initid, UDF_ARGS *args, char *message)
{
    if (args->arg_count < 2 || args->arg_count > 3)
    {
        strcpy(message, "levenshtein() expects 2 or 3 arguments: (str1, str2, [ignore_case])");
        return 1;
    }
    return 0;
}

/**
 * UDF deinitialization (not used)
 */
void levenshtein_deinit(UDF_INIT *initid)
{
    // No resources to free up
}
