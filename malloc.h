#ifndef MALLOC_H
#define MALLOC_H

/* Obtém o endereço de brk */
void setup_brk();

/* Restaura o endereço de brk */
void dismiss_brk();

/* Faz a alocação do bloco de memória do tamnaho desejado */
void* memory_alloc(unsigned long int bytes);


/* Marca um bloco ocupado como livre */
int memory_free(void *pointer);

#endif