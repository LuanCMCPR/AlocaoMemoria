#include <stdio.h>
#include <stdlib.h>

#include "malloc.h" 							

extern void *BRK_ATUAL;	/* Você precisa ter a variável global que armazena o valor de brk como um extern aqui.
							No código de teste estou chamandando de original_brk, mas se utilizarem outro nome,
							substituir as ocorrências por ele aqui. */

int main() { 

	printf("============================== ROTINAS DE TESTE ==============================\n");
	
	setup_brk();
	void *BRK_INICIAL = BRK_ATUAL;
	void *f_pnt, *s_pnt, *t_pnt, *q_pnt;

	f_pnt = memory_alloc(100);
	printf("==>> ALOCANDO UM ESPAÇO DE 100 BYTES:\n");
	printf("\tLOCAL: %s\n", f_pnt-16 == BRK_INICIAL ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (f_pnt-16)) == 1 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (f_pnt-8)) == 100 ? "CORRETO!" : "INCORRETO!");

	printf("==>> DESALOCANDO UM ESPAÇO DE 100 BYTES:\n");
	memory_free(f_pnt);
	printf("\tIND. DE USO: %s\n", *((long long*) (f_pnt-16)) == 0 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (f_pnt-8)) == 100 ? "CORRETO!" : "INCORRETO!");

	s_pnt = memory_alloc(50);
	t_pnt = memory_alloc(100);
	// q_pnt = memory_alloc(50);
	printf("==>> ALOCANDO UM ESPAÇO DE 50 BYTES:\n");
	printf("\tLOCAL: %s\n", s_pnt-16 == BRK_INICIAL ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (s_pnt-16)) == 1 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (s_pnt-8)) == 50 ? "CORRETO!" : "INCORRETO!");
	printf("==>> ALOCANDO UM ESPAÇO DE 100 BYTES:\n");
	printf("\tLOCAL: %s\n", s_pnt+100 == t_pnt-16 ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (t_pnt-16)) == 1 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (t_pnt-8)) == 100 ? "CORRETO!" : "INCORRETO!");
	printf("==> VERIFICANDO A FRAGMENTAÇÃO DE MEMÓRIA:\n");
	printf("\tIND. DE USO: %s\n", *((long long*) (s_pnt+50)) == 0 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (s_pnt+58)) == 34 ? "CORRETO!" : "INCORRETO!");

	printf("==>> DESALOCANDO TUDO:\n");
	// memory_free(f_pnt);
	// printf("bloco1 tam %d\n", *((long long*) (f_pnt-8)));
	// printf("bloco2 tam %d\n", *((long long*) (s_pnt-8)));
	// printf("bloco3 tam %d\n", *((long long*) (t_pnt-8)));
	// printf("bloco4 tam %d\n\n", *((long long*) (q_pnt-8)));
	// memory_free(s_pnt);
	// printf("bloco1 tam %d\n", *((long long*) (f_pnt-8)));
	// printf("bloco2 tam %d\n", *((long long*) (s_pnt-8)));
	// printf("bloco3 tam %d\n", *((long long*) (t_pnt-8)));
	// printf("bloco4 tam %d\n\n", *((long long*) (q_pnt-8)));
	// memory_free(t_pnt);
	// printf("bloco1 tam %d\n", *((long long*) (f_pnt-8)));
	// printf("bloco2 tam %d\n", *((long long*) (s_pnt-8)));
	// printf("bloco3 tam %d\n", *((long long*) (t_pnt-8)));
	// printf("bloco4 tam %d\n\n", *((long long*) (q_pnt-8)));
	// memory_free(q_pnt);
	// printf("bloco1 tam %d\n", *((long long*) (f_pnt-8)));
	// printf("bloco2 tam %d\n", *((long long*) (s_pnt-8)));
	// printf("bloco3 tam %d\n", *((long long*) (t_pnt-8)));
	// printf("bloco4 tam %d\n\n", *((long long*) (q_pnt-8)));
	
	memory_free(s_pnt);
	memory_free(t_pnt);
	printf("\tIND. DE USO: %s\n", *((long long*) (s_pnt-16)) == 0 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (s_pnt-8)) == 50 ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (t_pnt-16)) == 0 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (t_pnt-8)) == 100 ? "CORRETO!" : "INCORRETO!");


	printf("==>> DESALOCANDO A PILHA (ILEGAL):\n");
	unsigned long long stack_var = 0;
	unsigned int alloc_return = memory_free((void*) &stack_var);
	if (!alloc_return) printf("\tO RETORNO DA LIBERAÇÃO FOI NULL!\n");

	return 0;
}
