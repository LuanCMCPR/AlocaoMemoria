.section .data
.global BRK_INICIAL
BRK_INICIAL: .quad 0
.global BRK_ATUAL
BRK_ATUAL: .quad 0

.section .text
.global get_brk
.global setup_brk
.global dismiss_brk
.global memory_alloc
.global memory_free

get_brk:
	pushq   %rbp                # Empilha endereco-base do registro de ativacao antigo
	movq    %rsp, %rbp          # Atualiza ponteiro para endereco-base do registro de ativacao atual
	movq    $12, %rax  	        # ID do servico brk
	movq    $0, %rdi            # Parametro da chamada (de modo a retornar a altura atual da brk)
	syscall                    	# Chamada ao sistema
	popq    %rbp                # Desmonta registro de ativacao atual e restaura ponteiro para o antigo
	ret                         # Retorna

setup_brk:
	pushq   %rbp                # Empilha Endereço Base
	movq    %rsp, %rbp          # Atualiza ponteiro para o registro de ativação atual
	movq    $12, %rax           # ID da syscall de brk
	movq    $0 , %rdi           # Parametro da syscall ( 0, retorna a posição atual da heap)
	syscall                     # Chamada o S.O
	movq    %rax, BRK_INICIAL   # Salva valor de retorno da syscall em BRK_INICIAL
	movq    %rax, BRK_ATUAL     # Salva valor de retorno da syscall em BRK_ATUAL
	popq    %rbp                # Desempilha Registro de Ativação e restaura rbp para o valor anterior
	ret                         # Retorna

dismiss_brk:
	pushq   %rbp                # Empilha Endereço Base
	movq    %rsp, %rbp          # Atualiza ponteiro para o registro de ativação atual
	movq    $12, %rax           # ID da syscall de brk
	movq    BRK_INICIAL, %rdi   # Parametro da syscall(retorna a posição inicual da heap)
	syscall                     # Chamada o S.O
	popq    %rbp                # Desempilha Registro de Ativação e restaura rbp para o valor anterior
	ret 						# Retorna

memory_alloc:
	push    %rbp 				# Empilha Endereço Base
	movq    %rsp, %rbp			# Atualiza ponteiro para o registro de ativação atual
	
	pushq 	%rdi
	call	get_brk				# Atualiza brk_atual
	movq	%rax, BRK_ATUAL
	popq	%rdi

	movq	BRK_INICIAL, %rbx 	# Guarda inicial em %rbx, servindo como um iterador(i)
	cmpq 	%rbx, BRK_ATUAL		# Compara brk inicial com atual
	jl falha					# se atual < inicial, falha

	# rdi tem o numero de bytes
	cmpq	$0, %rdi 			# Se pediu pra alocar 0 bytes, finaliza
	je		falha

	addq	$16, %rbx
	while:
		cmpq	BRK_ATUAL, %rbx 	# Compara i com atual
		jge		blocoNovo 			# Se i >= atual, chegou no final e nao encontrou, cria bloco novo

		# Procura bloco vazio
		movq 	$0, %r12
		cmpq	%r12, -16(%rbx)		# Se USO eh 0, nao avanca
		je if
		avancarBloco:
		addq	-8(%rbx), %rbx		# adiciona TAMANHO do bloco ao i
		addq	$16, %rbx			# mais 16 no i
		jmp while					# testa se estourou brk

		if:
			cmpq	%rdi, -8(%rbx)		# Testa se bloco tem espaco
			jl		avancarBloco		# Nao tem espaco
			# Tem espaco
			movq	$1, -16(%rbx)		# Bloco agora esta em uso
			movq	%rbx, %rax			# Salva na saida, endereco do bloco

			# Criar proximo bloco
			movq 	-8(%rbx), %r12		# r12 = tamanho antigo
			subq	%rdi, %r12			# r12 -= tamanho novo alocacao
			subq	$16, %r12			# r12 -= 16
			movq 	$0, %r13
			cmpq    %r13, %r12			# se r12 < 0, nao precisa criar novo bloco menor
			jl 		saida

			movq 	%rdi, -8(%rbx)		# Atualiza tamanho do bloco antigo
			# cria bloco novo
			addq	%rdi, %rbx			# Pula pro proximo bloco
			movq 	$0, (%rbx)			# Proximo nao esta em uso
			movq 	%r12, 8(%rbx)		# proximo tem tamanho r12
			jmp 	saida

	blocoNovo:
	# Abrir espaco no final da heap, com o tamanho de bytes

	pushq 	%rdi				# guarda numero de bytes
	addq 	BRK_ATUAL, %rdi		# Parametro da chamada (brk + numero de bytes)
	addq 	$16, %rdi			# Parametro + 16
	movq    $12, %rax  	        # ID do servico brk        
	syscall                 	# Chamada ao sistema, abrir espaco na heap
	popq 	%rdi

	movq 	BRK_ATUAL, %r12		# brk_atual em variavel

	movq 	$1, (%r12)			# Marca novo bloco como utilizado
	movq	%rdi, 8(%r12)		# Marca tamanho bytes em novo bloco
	addq	$16, %r12	
	movq 	%r12, %rax 			# Endereco do bloco para a saida
	
	saida:
	popq    %rbp                # Desempilha Registro de Ativação e restaura rbp para o valor anterior
	ret                         # Retorna

	falha:
	movq    $-1 , %rax         	# Retorna -1, falha
	popq    %rbp                # Desempilha Registro de Ativação e restaura rbp para o valor anterior
	ret  

memory_free:
	push    %rbp				# Empilha Endereço Base
	movq    %rsp, %rbp          # Atualiza ponteiro para o registro de ativação atual
	movq    %rdi, %rbx          # Move o valor de endereço do parametro para %rbx
	cmpq    $0, %rbx            # Compara se endereco passado é NULO
	je      exit
	cmpq    BRK_INICIAL, %rbx   # Compara se endereco passado é menor que o BRK_INICIAL
	jl      exit
	call    get_brk             # Obtem o valor atual de brk
	cmpq    %rax, %rbx          # Compara se Endereco passado é maior que o BRK_ATUAL
	jg      exit
	movq    $0, -16(%rbx)       # Zera o USO do bloco

	# unir blocos vazios consecutivos
	movq	BRK_INICIAL, %rbx	# rbx vira inicial(iterador)
	addq 	$16, %rbx
	movq 	%rbx, %r12			# guarda local
	movq	-8(%rbx), %r13		# guarda tamanho
	whileFrag:
		cmpq	%rax, %rbx		# iterador chegou no fim da heap
		jge	sucesso
		
		cmpq	$0, -16(%rbx)	# se bloco estiver livre, testa
		je 		testa
		addq	%r13, %rbx		# avanca para proximo
		addq	$16, %rbx
		movq 	%rbx, %r12			# guarda local
		movq	-8(%rbx), %r13		# guarda tamanho
		jmp whileFrag

		testa:
		cmpq	%r12, %rbx		# testa se ja andou
		jg andou				# rbx > r12
		addq	%r13, %rbx		# avanca para proximo
		addq	$16, %rbx
		jmp whileFrag

		andou:
		addq	-8(%rbx), %r13	# somar tamanho
		addq	$16, %r13		
		movq	%r13, -8(%r12)	# ajusta tamanho
		addq	-8(%rbx), %rbx	# avanca para proximo
		addq	$16, %rbx
		jmp whileFrag

	sucesso:
	movq    $1, %rax            # Retorna 1, sucesso
	popq    %rbp                # Desempilha Registro de Ativação e restaura rbp para o valor anterior
	ret                         # Retorna
	exit:
	movq    $0, %rax            # Retorna 0, falha
	popq    %rbp                # Desempilha Registro de Ativação e restaura rbp para o valor anterior
	ret                         # Retorna
