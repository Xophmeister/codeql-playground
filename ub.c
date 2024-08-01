#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
  size_t size = 5;
  int* buffer = (int*)malloc(size * sizeof(int));

  if (buffer == NULL) {
    /* Null-pointer dereference */
    printf("%d\n", *buffer);

    exit(1);
  }

  /* Buffer overflow */
  for (size_t i = 0; i <= size; ++i) {
    *(buffer + i) = (int)i;
  }

  /* Double free */
  for (size_t j = 0; j < 2; ++j) {
    free(buffer);
  }

  return 0;
}
