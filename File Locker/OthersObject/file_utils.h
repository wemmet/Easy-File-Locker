#ifndef file_utils_h
#define file_utils_h
#include <fcntl.h>
int open_file(const char *path, int flags, mode_t mode);
#endif /* file_utils_h */
