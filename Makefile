CC=gcc
NV=nvcc
ARCH=sm_61
CFLAGS=-Wall
NVFLAGS=-Xptxas -v
INC=-Iinc

1a:
	$(CC) src/1a.c -o bin/1a -lm
2b:
	$(CC) src/2a.c -o bin/2a -lm
