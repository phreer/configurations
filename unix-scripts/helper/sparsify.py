#!/usr/bin/env python3
import os
import sys
import ctypes
import ctypes.util

# Linux fallocate flags
FALLOC_FL_KEEP_SIZE = 0x01
FALLOC_FL_PUNCH_HOLE = 0x02

libc = ctypes.CDLL(ctypes.util.find_library("c"), use_errno=True)
libc.fallocate.argtypes = [
    ctypes.c_int,
    ctypes.c_int,
    ctypes.c_longlong,
    ctypes.c_longlong,
]
libc.fallocate.restype = ctypes.c_int


def punch_hole(fd, offset, length):
    ret = libc.fallocate(
        fd,
        FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
        offset,
        length,
    )
    if ret != 0:
        err = ctypes.get_errno()
        raise OSError(err, os.strerror(err))


def is_all_zero(buf):
    return not any(buf)


def sparsify(path, chunk_size=1024 * 1024):
    st = os.stat(path)
    size = st.st_size

    with open(path, "r+b", buffering=0) as f:
        fd = f.fileno()

        zero_start = None
        offset = 0

        while offset < size:
            to_read = min(chunk_size, size - offset)
            buf = f.read(to_read)

            if is_all_zero(buf):
                if zero_start is None:
                    zero_start = offset
            else:
                if zero_start is not None:
                    punch_hole(fd, zero_start, offset - zero_start)
                    print(f"punched: {zero_start}-{offset}")
                    zero_start = None

            offset += len(buf)

        if zero_start is not None:
            punch_hole(fd, zero_start, offset - zero_start)
            print(f"punched: {zero_start}-{offset}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} FILE")
        sys.exit(1)

    sparsify(sys.argv[1])
