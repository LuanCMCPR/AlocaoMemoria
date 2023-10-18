#!bin/bash

# Luan Carlos Maia Cruz - GRR 20203891
# Felipe Augusto Dittert Noleto - GRR20205689

# Script para gerar o executavel
as Allocator.s -o Allocator.o -g
gcc -g -Wall -c main.c -o main.o
ld Allocator.o main.o -o Allocator  -dynamic-linker -lc