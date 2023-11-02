#include <stdio.h>
#include "malloc.h"


int main() 
{

    // void *a,*b,*c,*d,*e;
    // printf("Teste de alocação de memória\n");
    printf("Inicializando\n");
    setup_brk();

    void *p;

    p = (void *) memory_alloc(100);
    printf("%p\n",  p);
    // printf("%lu\n",  p);
    // print_heap();

    // b = (void *) memory_alloc(100);
    // print_heap();

    // c = (void *) memory_alloc(200);
    // print_heap();

    // d = (void *) memory_alloc(250);
    // print_heap();

    // e = (void *) memory_alloc(300);
    // print_heap();

    // memory_free(b);
    // print_heap();

    // memory_free(d);
    // print_heap();

    // memory_free(a);
    // print_heap();

    // memory_free(c);
    // print_heap();

    // memory_free(e);
    // print_heap();

    dismiss_brk();
    // printf("Liberando\n");

    return 0;
}