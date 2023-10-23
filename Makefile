# Luan Carlos Maia Cruz - GRR 20203891
# Felipe Augusto Dittert Noleto - GRR20205689

CC = gcc
# LD = ld
EXEC = allocator
CFLAGS = -g -Wall -no-pie
# LDFILES =  /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \/usr/lib/x86_64-linux-gnu/crt1.o  /usr/lib/x86_64-linux-gnu/crti.o \/usr/lib/x86_64-linux-gnu/crtn.o
OBJECTS: main.o allocator.o
DIR = fadn20-lcmc20
FILES = *.c *.h *.s Makefile Relatório.pdf

all: $(EXEC)

$(EXEC): $(OBJECTS)
	$(CC) $(CFLAGS) -o $(EXEC) $(OBJECTS)

# dynamic-linker $(LDFILES) -lc
main.o: main.c
	$(CC) $(CFLAGS) -c main.c

allocator.o: allocator.s malloc.h
	as allocator.s -o allocator.o

# Remove arquivos objeto, temporários e executável
clean:
	@echo "Limpando sujeira..."
	rm -f *.o $(EXEC) *~ 

# Gera um arquivo compactado com os arquivos necessários para execução do programa
compact:
	@echo "Compactando arquivos..."
	tar -czvf $(DIR).tar.gz $(addprefix ../$(DIR)/, $(FILES))













#https://github.com/sulzbals/malloc/blob/master/src/malloc.s