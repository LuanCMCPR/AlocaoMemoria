
# memory_alloc:
;     pushq       %rbp                    # Empilha endereco-base do registro de ativacao antigo
;     movq        %rsp, %rbp              # Atualiza ponteiro para endereco-base do registro de ativacao atual
;     movq        $0, %rax                # Obtem 0 (que indica !isRunning)
;     movq        isRunning, %rbx         # Obtem isRunning
;     cmpq        %rax, %rbx              # Verifica o valor de isRunning (se o alocador ja foi iniciado)
;     jne         start                   # Se o alocador foi iniciado, desvia para o comeco, efetivamente
;     pushq       %rdi                    # Caller save do parametro num_bytes
;     call        setup_brk          # Se não, inicia o alocador
;     popq        %rdi                    # Restaura parametro num_bytes
;     movq        $1, isRunning           # Indica que o alocador foi iniciado
;   start:
;     pushq       %rdi                    # Caller save do parametro num_bytes
;     call        brkGet                  # Obtem ponteiro para final da heap
;     popq        %rdi                    # Restaura parametro num_bytes
;     pushq       %rax                    # Aloca variavel local que aponta para o fim da heap
;     movq        -8(%rbp), %rsi          # Estabelece ponteiro para fim da heap como segundo parametro
;     pushq       %rdi                    # Caller save do parametro num_bytes
;     call        FIT_ALGORITHM           # Chama funcao para encontrar bloco livre
;     popq        %rdi                    # Restaura parametro num_bytes
;     pushq       %rax                    # Aloca variavel local com ponteiro para bloco a ser alocado
;     movq        -16(%rbp), %rax         # Obtem ponteiro para informacao gerencial do bloco a ser alocado
;     movq        $0, %rbx                # Obtem 0 (que indica que nao ha blocos livres utilizaveis)
;     cmpq        %rax, %rbx              # Verifica se ha um bloco livre utilizavel
;     jne         fit                     # Se sim, desvia para fit
;     movq        %rdi, %rax              # Obtem parametro num_bytes
;     movq        -8(%rbp), %rbx          # Obtem ponteiro para topo atual da heap
;     addq        $16, %rbx               # Obtem ponteiro para inicio do bloco a ser alocado
;     addq        %rax, %rbx              # Obtem ponteiro para final do bloco a ser alocado
;     pushq       %rdi                    # Caller save do parametro num_bytes
;     movq        %rbx, %rdi              # Parametro da chamada (de modo a atualizar a altura da brk)
;     call        brkUpdate               # Atualiza topo da heap
;     popq        %rdi                    # Restaura parametro num_bytes
;     movq        -8(%rbp), %rax          # Obtem ponteiro para fim da heap
;     movq        %rax, -16(%rbp)         # Atualiza ponteiro para informacao gerencial do bloco a ser alocado
;     jmp         done                    # Desvia para o final da funcao
;   fit:
;     movq        -16(%rbp), %rax         # Obtem ponteiro para informacao gerencial
;     movq        8(%rax), %rax           # Obtem tamanho do bloco
;     movq        %rdi, %rbx              # Obtem parametro num_bytes
;     cmpq        %rax, %rbx              # Compara num_bytes com tamanho do bloco
;     je          done                    # Se o bloco tem o tamanho certo, desvia para o fim da funcao
;     movq        -16(%rbp), %rax         # Obtem ponteiro para informacao gerencial
;     movq        %rdi, %rbx              # Obtem parametro num_bytes
;     movq        8(%rax), %rax           # Obtem tamanho do bloco
;     subq        %rbx, %rax              # Subtrai tamanho a ser alocado
;     movq        $16, %rbx               # Obtem 16 (espaco a ser ocupado pelas informacoes gerenciais)
;     cmpq        %rax, %rbx              # Verifica se o bloco restante e grande o suficiente
;     jl          proceed                 # Se sim, continua a configuracao do bloco restante
;     movq        -16(%rbp), %rax         # Obtem ponteiro para informacao gerencial
;     movq        8(%rax), %rax           # Obtem tamanho do bloco
;     movq        %rax, %rdi              # Assume que o tamanho do bloco a ser alocado e o mesmo do bloco antes vazio
;     jmp         done                    # Desvia para o fim da funcao
;   proceed:
;     movq        -16(%rbp), %rax         # Obtem ponteiro para informacao gerencial
;     movq        %rdi, %rbx              # Obtem parametro num_bytes
;     movq        8(%rax), %rsi           # Obtem tamanho do bloco
;     subq        %rbx, %rsi              # Subtrai tamanho a ser alocado
;     subq        $16, %rsi               # Subtrai espaco ocupado pelas informacoes gerenciais
;     addq        $16, %rax               # Obtem ponteiro para início do bloco a ser alocado
;     addq        %rbx, %rax              # Obtem ponteiro para final do bloco a ser alocado e inicio do bloco livre restante
;     movq        $0, (%rax)              # Indica que o bloco restante esta livre
;     movq        %rsi, 8(%rax)           # Estabelece tamanho do bloco restante
;   done:
;     movq        -16(%rbp), %rax         # Obtem ponteiro para informacao gerencial alocada
;     movq        $1, (%rax)              # Indica que o bloco alocado esta ocupado
;     addq        $8, %rax                # Obtem ponteiro para tamanho do bloco alocado
;     movq        %rdi, (%rax)            # Estabelece tamanho do bloco alocado (num_bytes)
;     addq        $8, %rax                # Obtem ponteiro para bloco alocado
;     addq        $16, %rsp               # Desempilha variaveis locais
;     popq        %rbp                    # Desmonta registro de ativacao atual e restaura ponteiro para o antigo
;     ret                                 # Retorna


memory_alloc:
    pushq %rbp
    movq %rsp, %rbp

    movq BRK_ATUAL, %rbx        # %rbx (topo) <-- BRK_ATUAL
    movq INICIO_HEAP, %rcx      # %rcx (i) <-- INICIO_HEAP

    # itera cada bloco da heap até chegar no topo
    while:
    cmpq %rbx, %rcx             # %rcx (i) >= %rbx (topo) ==> fim_while
    jge fim_while
        movq (%rcx), %rdx       # %rdx (bit_ocupado) <-- M[%rcx]
        movq 8(%rcx), %rsi      # %rsi (tamanho) <-- M[%rcx + 8]BRK_ATUAL

        # verifica se o bloco está livre
        cmpq $0, %rdx           # %rdx (bit_ocupado) != 0 ==> fim_if
        jne fim_if
            # verifica se o tamanho do bloco é suficiente
            cmpq 16(%rbp), %rsi         # %rsi (tamanho) < num_bytes ==> fim_if
            jl fim_if
                movq $1, (%rcx)         # informa que o bloco está ocupado
                addq $16, %rcx
                movq %rcx, %rax         # retorna o endereço do bloco (início do conteúdo)
                popq %rbp
                ret
      
        fim_if:
        # rcx passa a apontar para o início do próximo bloco
        addq $16, %rcx          # %rcx (i) <-- %rcx (i) + 16
        addq %rsi, %rcx         # %rcx (i) <-- %rcx (i) + %rsi (tamanho)
        jmp while

    fim_while:
    # obtém o endereço do topo do último bloco alocado e o endereço do topo dos bytes alocados na heap
    movq BRK_ATUAL, %rdx        # %rdx <-- BRK_ATUAL (último bloco alocado)
    movq TOPO_ALOCADO, %rcx     # %rcx <-- TOPO_ALOCADO (topo dos bytes alocados na heap)

    movq 16(%rbp), %rbx         # %rbx <-- num_bytes (parâmetro)
    addq $16, %rbx              # %rbx <-- num_bytes + 16

    # verifica se não há espaço suficiente para o bloco dentro dos bytes já alocados
    subq %rdx, %rcx             # %rdx <-- TOPO_ALOCADO - BRK_ATUAL
    cmpq %rcx, %rbx             # %rbx (num_bytes + 16) <= %rcx (TOPO_ALOCADO - BRK_ATUAL) ==> fim_if2
    jle fim_if2
        subq %rcx, %rbx             # %rbx <-- num_bytes + 16 - (TOPO_ALOCADO - BRK_ATUAL)

        # calcula o número de K (%rbx) blocos de 4096 bytes necessários
        subq $1, %rbx               # %rbx -= 1
        shr $12, %rbx               # %rbx /= 4096
        addq $1, %rbx               # %rbx += 1
        
        # calcula o número de bytes necessários e adiciona ao TOPO_ALOCADO
        shl $12, %rbx               # %rbx *= 4096
        addq %rbx, TOPO_ALOCADO     # TOPO_ALOCADO += rbx

        # chama brk para aumentar o tamanho da heap
        movq TOPO_ALOCADO, %rdi     # %rdi <-- TOPO_ALOCADO
        movq $12, %rax              # chamada de sistema para o brk
        syscall    

    fim_if2:
    movq BRK_ATUAL, %rbx    # %rbx <-- BRK_ATUAL

    movq $1, (%rbx)         # M[%rbx] <-- 1 (bit_ocupado)
    movq 16(%rbp), %rcx     # %rcx <-- num_bytes (parâmetro)
    movq %rcx, 8(%rbx)      # M[%rbx + 8] <-- num_bytes (parâmetro)
    
    addq $16, BRK_ATUAL     # BRK_ATUAL += 16
    addq %rcx, BRK_ATUAL    # BRK_ATUAL += num_bytes (parâmetro)
    
    addq $16, %rbx          # %rbx <-- %rbx + 8
    movq %rbx, %rax         # %rax <-- %rbx (endereço do bloco)

    popq %rbp
    ret



first_fit:
    pushq       %rbp                    # Empilha endereco-base do registro de ativacao antigo
    movq        %rsp, %rbp              # Atualiza ponteiro para endereco-base do registro de ativacao atual
    movq        BRK_INICIAL, %rax       # Obtem topoInicialHeap
    pushq       %rax                    # Aloca variavel local que aponta para a primeira informacao gerencial
  LOOP_FIT:
    movq        -8(%rbp), %rax         # Obtem ponteiro para informacao gerencial do bloco atual
    movq        BRK_ATUAL, %rbx              # Obtem ponteiro para fim da heap
    cmpq        %rax, %rbx              # Compara fim da heap com ponteiro para informacao gerencial atual
    jle         NOT_FIT       # Se nao ha blocos liberados utilizaveis, sai do laco com status "not fit"
    movq        -8(%rbp), %rax          # Obtem ponteiro para informacao gerencial do bloco atual
    movq        (%rax), %rax            # Obtem informacao gerencial do bloco atual
    movq        $0, %rbx                # Obtem 0 (que indica "livre")
    cmpq        %rax, %rbx              # Compara 0 com informacao gerencial do bloco atual
    jne         DO_LOOP_FIT       # Se o bloco nao esta livre, continua no laco
    movq        -8(%rbp), %rax          # Obtem ponteiro para informacao gerencial do bloco atual
    movq        8(%rax), %rax           # Obtem tamanho do bloco atual
    movq        %rdi, %rbx              # Obtem parametro num_bytes
    cmpq        %rax, %rbx              # Compara num_bytes com tamanho do bloco atual
    jle         FIT           # Se o bloco atual e grande o suficiente, sai do laco com status "fit"
  DO_LOOP_FIT:
    movq        -8(%rbp), %rax          # Obtem ponteiro para informacao gerencial do bloco atual
    movq        8(%rax), %rbx           # Obtem tamanho do bloco atual
    addq        $16, %rax               # Obtem ponteiro para inicio do bloco atual
    addq        %rbx, %rax              # Obtem ponteiro para a proxima informacao gerencial
    movq        %rax, -8(%rbp)          # Atualiza variavel com ponteiro para proxima informacao gerencial
    jmp         LOOP_FIT          # Continua no laco
  NOT_FIT:
    movq        $0, %rax                # Retorna 0 (nao ha blocos livres utilizaveis)
    jmp         DONE          # Desvia para final da funcao
  FIT:
    movq        -8(%rbp), %rax          # Retorna ponteiro para informacao gerencial do bloco atual
  DONE:
    addq        $8, %rsp                # Desempilha variaveis locais
    popq        %rbp                    # Desmonta registro de ativacao atual e restaura ponteiro para o antigo
    ret                                 # Retorna
