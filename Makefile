# $(EXEC): $(OBJECTS) $(CC) $(CFLAGS) -o $(EXEC) $(OBJECTS) 

teste: main.c allocator.o
	gcc -no-pie -z noexecstack main.c allocator.o -o teste

allocator.o: allocator.s malloc.h
	as allocator.s -o allocator.o

# Remove arquivos objeto, temporários
clean:
	@echo "Limpando sujeira..."
	rm -f *.o *~ teste

# Remove arquivos objeto, temporários, executável
purge: clean
	@echo "Faxina..."
	rm -f $(EXEC) 

# Gera um arquivo compactado com os arquivos necessários para execução do programa
compact:
	@echo "Compactando arquivos..."
	tar -czvf $(DIR).tar.gz $(addprefix ../$(DIR)/, $(FILES))

