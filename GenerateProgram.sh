#!bin/bash

# Luan Carlos Maia Cruz - GRR 20203891
# Felipe Noleto - GRR

# Script para gerar o executavel
as OwnAllocator.s -o OwnAllocator.o -g
gcc -g -Wall -c main.c -o main.o
ld OwnAllocator.o main.o -o OwnAllocator  -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \/usr/lib/x86_64-linux-gnu/crt1.o  /usr/lib/x86_64-linux-gnu/crti.o \/usr/lib/x86_64-linux-gnu/crtn.o -lc