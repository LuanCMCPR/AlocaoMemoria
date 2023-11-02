# Luan Carlos Maia Cruz - GRR 20203891
# Felipe Augusto Dittert Noleto - GRR20205689

CC = gcc
# LD = ld
EXEC = allocator
CFLAGS = -Wall -no-pie
LDFILES =  /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \/usr/lib/x86_64-linux-gnu/crt1.o  /usr/lib/x86_64-linux-gnu/crti.o \/usr/lib/x86_64-linux-gnu/crtn.o
# OBJECTS: main.o $(EXEC).o
# OBJECTS: *.o
DIR = fadn20-lcmc20
FILES = *.c *.h *.s Makefile Relatório.pdf

all: $(EXEC)

# $(EXEC): $(OBJECTS) $(CC) $(CFLAGS) -o $(EXEC) $(OBJECTS) 

# dynamic-linker $(LDFILES) -lc
$(EXEC): main.o $(EXEC).o
	ld main.o $(EXEC).o -o $(EXEC) -dynamic-linker $(LDFILES) -lc

main.o: main.c

$(EXEC).o: $(EXEC).s malloc.h
	as $(EXEC).s -o $(EXEC).o

# Remove arquivos objeto, temporários
clean:
	@echo "Limpando sujeira..."
	rm -f *.o *~

# Remove arquivos objeto, temporários, executável
purge: clean
	@echo "Faxina..."
	rm -f $(EXEC) 

# Gera um arquivo compactado com os arquivos necessários para execução do programa
compact:
	@echo "Compactando arquivos..."
	tar -czvf $(DIR).tar.gz $(addprefix ../$(DIR)/, $(FILES))













#https://github.com/sulzbals/malloc/blob/master/src/malloc.s