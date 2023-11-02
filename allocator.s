.section .data
BRK_INICIAL: .quad 0
BRK_ATUAL: .quad 0
IN_USE: .string "+"
NOT_IN_USE: .string "-"

.section .text
.global setup_brk
.global dismiss_brk
.global memory_alloc
.global memory_free
.global print_heap
.global print

setup_brk:
# Executa a syscall de brk para obter o endereço atual do topo da heap e o armazena em BRK_INICIAL e BRK_ATUAL

  # Empilha rbp
  pushq %rbp
  movq %rsp, %rbp

  # Retorna endereço atual de brk
  movq $12, %rax              
  movq $0 , %rdi
  syscall

  # Salva o valor atual de brk em BRK_INICIAL e BRK_ATUAL
  movq %rax, BRK_INICIAL      
  movq %rax, BRK_ATUAL

  # Desempilha rbp
  popq %rbp
  ret

dismiss_brk:
# Executa a syscall de brk para restaurar ao endereço inicial da heap

  # Empilha rbp 
  pushq %rbp
  movq %rsp, %rbp

  # Restaura o endereço de brk para o endereço inicial da heap, salvo em BRK_INICIAL
  movq $12, %rax             
  movq BRK_INICIAL, %rdi
  syscall

  # Desempilha rbp
  popq %rbp
  ret

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
# Marca um bloco ocupado como livre
# vai direto no ponteiro q passou, e muda USO para livre

  # Empilha rbp
  push %rbp
  movq %rsp, %rbp

  # Compara se endereco passado é NULO
  cmpq $0, %rdi
  je exit
  
  # Compara se endereco passado é menor que o BRK_INICIAL  
  cmpq BRK_INICIAL, %rdi
  jl exit

  # Compara se Endereco passado é maior que o BRK_ATUAL
  cmpq BRK_ATUAL, %rdi
  jge exit

  # Zera o USO do bloco
  movq %rdi, %rax
  subq $16, %rax
  movq $0, %rax

  # Desempilha rbp
  popq %rbp
  ret

  exit:
  movq $0, %rax

  # Desempilha rbp
  popq %rbp
  ret
