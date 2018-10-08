CC=gcc
NV=nvcc
ARCH=sm_61
CFLAGS=-Wall -std=c99
NVFLAGS=-Xptxas -v
INC=-Iinc

1a:
	$(CC) $(CFLAGS) src/1a.c -o bin/1a -lm
1b:
        $(NV) src/1b.cu -o bin/1b

2a:
	$(CC) $(CFLAGS) src/2a.c -o bin/2a -lm
2b:    
	$(NV) src/2b.cu -o bin/2b
