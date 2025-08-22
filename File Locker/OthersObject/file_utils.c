#include <fcntl.h>
int open_file(const char *path, int flags, mode_t mode) {
    return open(path, flags, mode);
}
