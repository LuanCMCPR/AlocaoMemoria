.section .data
BRK_INICIAL: .quad 0
BRK_ATUAL: .quad 0

.section .text
.global get_brk
.global setup_brk
.global dismiss_brk
.global memory_alloc
.global memory_free

get_brk:
  pushq   %rbp                  # Empilha endereco-base do registro de ativacao antigo
  movq    %rsp, %rbp            # Atualiza ponteiro para endereco-base do registro de ativacao atual
  movq    $12, %rax             # ID do servico brk
  movq    $0, %rdi              # Parametro da chamada (de modo a retornar a altura atual da brk)
  syscall                       # Chamada ao sistema
  popq    %rbp                  # Desmonta registro de ativacao atual e restaura ponteiro para o antigo
  ret                           # Retorna

setup_brk:
  pushq   %rbp                  # Empilha Endereço Base
  movq    %rsp, %rbp            # Atualiza ponteiro para o registro de ativação atual
  movq    $12, %rax             # ID da syscall de brk
  movq    $0 , %rdi             # Parametro da syscall ( 0, retorna a posição atual da heap)
  syscall                       # Chamada o S.O
  movq    %rax, BRK_INICIAL     # Salva valor de retorno da syscall em BRK_INICIAL
  movq    %rax, BRK_ATUAL       # Salva valor de retorno da syscall em BRK_ATUAL
  popq    %rbp                  # Desempilha Registro de Ativação e restaura rbp para o valor anterior
  ret                           # Retorna

dismiss_brk:
  pushq   %rbp                  # Empilha Endereço Base
  movq    %rsp, %rbp            # Atualiza ponteiro para o registro de ativação atual
  movq    $12, %rax             # ID da syscall de brk
  movq    BRK_INICIAL, %rdi     # Parametro da syscall(retorna a posição inicual da heap)
  syscall                       # Chamada o S.O
  popq    %rbp                  # Desempilha Registro de Ativação e restaura rbp para o valor anterior
  ret                           # Retorna

memory_alloc:
# BRK_INICIAL = setup_TOPO();

# 1. Procura bloco livre com tamanho igual ou maior que a requisição
    # a partir do BRK_INICIAL até o BRK_ATUAL, percorrer heap, checar tamanho e se esta livre

# 2. Se encontrar, marca ocupação, utiliza os bytes necessários do bloco
    # se estiver livre e tiver tamanhor
        # alterar para ocupado
        # alterar tamanho para novo tamanho
        # alocar bloco não livre com o tamanho passado em bytes
        # e alocar um novo bloco nao livre, com o resto do bloco original (tamanhoOriginal - bytes - 16)
            # parte de USO deve ser 0, e tamanho deve ser (tamanhoOriginal - bytes - 16)
    # sempre retornar o endereco correspondente, do novo bloco
    
# 3. Se não encontrar, abre espaço para um novo bloco
    # se nao estiver nenhum livre
        # BRK_ATUAL = BRK_ATUAL + bytes
        # criar um novo bloco com tamanho bytes no final da heap
# sempre retornar o endereco correspondente, do novo bloco

memory_free:
  push    %rbp                  # Empilha Endereço Base
  movq    %rsp, %rbp            # Atualiza ponteiro para o registro de ativação atual
  movq    %rdi, %rbx            # Move o valor de endereço do parametro para %rbx
  cmpq    $0, %rbx              # Compara se endereco passado é NULO
  je      exit
  cmpq    BRK_INICIAL, %rbx     # Compara se endereco passado é menor que o BRK_INICIAL
  jl      exit
  call   get_brk               # Obtem o valor atual de brk
  cmpq    %rax, %rbx            # Compara se Endereco passado é maior que o BRK_ATUAL
  jg      exit                  
  movq    $0, -16(%rdi)         # Zera o USO do bloco   
  movq    $1, %rax              # Retorna 1, sucesso
  popq    %rbp                  # Desempilha Registro de Ativação e restaura rbp para o valor anterior
  ret                           # Retorna
  exit:
  movq    $0, %rax              # Retorna 0, falha
  popq    %rbp                  # Desempilha Registro de Ativação e restaura rbp para o valor anterior
  ret                           # Retorna
