AS = nasm
CC = gcc

all: aprog cprog

aprog: main_a.o
	$(CC) -no-pie main_a.o -o aprog

cprog: main_c.o
	$(CC)  main_c.o -o cprog

main_a.o: main_fix_leak.asm
	$(AS) -felf64 -g -Fdwarf main_fix_leak.asm -o main_a.o

main_c.o: main.c
	$(CC) -c -g -Wall -Wextra -Wpedantic -std=c11  main.c -o main_c.o

clear:
	rm -f aprog cprog *.s *.o core 

