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
ub.c:18:5: warning: double-‘free’ of ‘buffer’ [CWE-415] [-Wanalyzer-double-free]
   18 |     free(buffer);
      |     ^~~~~~~~~~~~
  ‘main’: events 1-12
    |
    |    5 |   int* buffer = (int*)malloc(size * sizeof(int));
    |      |                       ^~~~~~~~~~~~~~~~~~~~~~~~~~
    |      |                       |
    |      |                       (1) allocated here
    |    6 |
    |    7 |   if (buffer == NULL) {
    |      |      ~
    |      |      |
    |      |      (2) assuming ‘buffer’ is non-NULL
    |      |      (3) following ‘false’ branch (when ‘buffer’ is non-NULL)...
    |......
    |   12 |   for (size_t i = 0; i <= size; ++i) {
    |      |               ~      ~~~~~~~~~
    |      |               |        |
    |      |               |        (5) following ‘true’ branch (when ‘i <= size’)...
    |      |               (4) ...to here
    |   13 |     *(buffer + i) = (int)i;
    |      |              ~
    |      |              |
    |      |              (6) ...to here
    |......
    |   17 |   for (size_t j = 0; j < 2; ++j) {
    |      |                      ~~~~~
    |      |                        |
    |      |                        (7) following ‘true’ branch (when ‘j <= 1’)...
    |      |                        (10) following ‘true’ branch (when ‘j <= 1’)...
    |   18 |     free(buffer);
    |      |     ~~~~~~~~~~~~
    |      |     |
    |      |     (8) ...to here
    |      |     (9) first ‘free’ here
    |      |     (11) ...to here
    |      |     (12) second ‘free’ here; first ‘free’ was at (9)
    |
```
