#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <errno.h>

// size of buffer for reading/writing file contents
#define BUFFER_SIZE 4096
// maximum path length, defined for portability
#define PATH_MAX 4096

int main(int argc, char *argv[]) {
    // check command-line arguments
    if (argc != 3) {
        fprintf(stderr, "usage: %s <directory> <output_file>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    char *directory = argv[1];
    char *output_file = argv[2];

    // extract the base name of the output file to exclude it from processing
    const char *output_basename = strrchr(output_file, '/');
    if (output_basename) {

    }
}
