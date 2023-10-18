#include <stdio.h>
#include "malloc.h"


int main()
{

    void *a,*b,*c,*d,*e;

    setup_brk();

    // a = memory_alloc(50);
    // printHeap();

    // b = memory_alloc(100);
    // printHeap();

    // c = memory_alloc(200);
    // printHeap();

    // d = memory_alloc(250);
    // printHeap();

    // e = memory_alloc(300);
    // printHeap();

    memory_free(b);
    // printHeap();

    memory_free(d);
    // printHeap();

    memory_free(a);
    // printHeap();

    memory_free(c);
    // printHeap();

    memory_free(e);
    // printHeap();

    dismiss_brk();

    return 0;
}