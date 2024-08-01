# CodeQL Playground

Let's write some [dodgy C code](/ub.c) to see what CodeQL, with the
default C/C++ queries, can catch.

## Results

CodeQL didn't catch anything :disappointed:

### Comparison

GCC's static analysis does a much better job:

```console
$ gcc -fanalyzer ub.c
ub.c: In function ‘main’:
ub.c:10:5: warning: dereference of NULL ‘buffer’ [CWE-476] [-Wanalyzer-null-dereference]
   10 |     printf("%d\n", *buffer);
      |     ^~~~~~~~~~~~~~~~~~~~~~~
  ‘main’: events 1-5
    |
    |    6 |   int* buffer = (int*)malloc(size * sizeof(int));
    |      |                       ^~~~~~~~~~~~~~~~~~~~~~~~~~
    |      |                       |
    |      |                       (1) allocated here
    |    7 |
    |    8 |   if (buffer == NULL) {
    |      |      ~
    |      |      |
    |      |      (2) assuming ‘buffer’ is NULL
    |      |      (3) following ‘true’ branch (when ‘buffer’ is NULL)...
    |    9 |     /* Null-pointer dereference */
    |   10 |     printf("%d\n", *buffer);
    |      |     ~~~~~~~~~~~~~~~~~~~~~~~
    |      |     |
    |      |     (4) ...to here
    |      |     (5) dereference of NULL ‘buffer’
    |
ub.c:10:5: warning: use of uninitialized value ‘*buffer’ [CWE-457] [-Wanalyzer-use-of-uninitialized-value]
   10 |     printf("%d\n", *buffer);
      |     ^~~~~~~~~~~~~~~~~~~~~~~
  ‘main’: events 1-4
    |
    |    6 |   int* buffer = (int*)malloc(size * sizeof(int));
    |      |                       ^~~~~~~~~~~~~~~~~~~~~~~~~~
    |      |                       |
    |      |                       (1) region created on heap here
    |    7 |
    |    8 |   if (buffer == NULL) {
    |      |      ~
    |      |      |
    |      |      (2) following ‘true’ branch (when ‘buffer’ is NULL)...
    |    9 |     /* Null-pointer dereference */
    |   10 |     printf("%d\n", *buffer);
    |      |     ~~~~~~~~~~~~~~~~~~~~~~~
    |      |     |
    |      |     (3) ...to here
    |      |     (4) use of uninitialized value ‘*buffer’ here
    |
ub.c:22:5: warning: double-‘free’ of ‘buffer’ [CWE-415] [-Wanalyzer-double-free]
   22 |     free(buffer);
      |     ^~~~~~~~~~~~
  ‘main’: events 1-12
    |
    |    6 |   int* buffer = (int*)malloc(size * sizeof(int));
    |      |                       ^~~~~~~~~~~~~~~~~~~~~~~~~~
    |      |                       |
    |      |                       (1) allocated here
    |    7 |
    |    8 |   if (buffer == NULL) {
    |      |      ~
    |      |      |
    |      |      (2) assuming ‘buffer’ is non-NULL
    |      |      (3) following ‘false’ branch (when ‘buffer’ is non-NULL)...
    |......
    |   16 |   for (size_t i = 0; i <= size; ++i) {
    |      |               ~      ~~~~~~~~~
    |      |               |        |
    |      |               |        (5) following ‘true’ branch (when ‘i <= size’)...
    |      |               (4) ...to here
    |   17 |     *(buffer + i) = (int)i;
    |      |              ~
    |      |              |
    |      |              (6) ...to here
    |......
    |   21 |   for (size_t j = 0; j < 2; ++j) {
    |      |                      ~~~~~
    |      |                        |
    |      |                        (7) following ‘true’ branch (when ‘j <= 1’)...
    |      |                        (10) following ‘true’ branch (when ‘j <= 1’)...
    |   22 |     free(buffer);
    |      |     ~~~~~~~~~~~~
    |      |     |
    |      |     (8) ...to here
    |      |     (9) first ‘free’ here
    |      |     (11) ...to here
    |      |     (12) second ‘free’ here; first ‘free’ was at (9)
    |
```
