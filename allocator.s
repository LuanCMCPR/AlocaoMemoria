.section .data
    BRK_INICIAL: .quad 0
    BRK_ATUAL: .quad 0

.section .text
.global get_brk
.global update_brk
.global setup_brk
.global dismiss_brk
.global memory_alloc
.global memory_free

# Retorna o endereço atual de brk
get_brk:
    pushq %rbp
    movq %rsp, %rbp
    movq $12, %rax              # Syscall para brk
    movq $0 , %rdi              # Retorna Endereço Atual  
    syscall
    popq %rbp
    ret 

# Atualiza o endereço de brk, o valor de do registrado %rdi deve ser atualizado antes 
update_brk:
    pushq %rbp
    movq %rsp, %rbp
    movq $12, %rax              # Syscall para brk
    syscall
    popq %rbp
    ret



setup_brk:
# Executa a syscall de TOPO para obter o endereço do topo correte da heap 
# e o armazena em BRK_INICIAL e BRK_ATUAL
    
    pushq %rbp           
    movq %rsp, %rbp     
    
    movq $12, %rax              # Syscall para brk
    movq $0 , %rdi              # Retorna Endereço Atual  
    syscall

    movq %rax, BRK_ATUAL
    movq %rax, BRK_INICIAL

    popq %rbp
    ret

dismiss_brk:
# 
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax              # Syscall para brk
    movq BRK_INICIAL, %rdi      # Restaura o endereço de BRK_INICIAL para brk
    syscall

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

# conectar os blocos livres
# segue do BRK_INICIAL ate o BRK_ATUAL, juntando o proximo livre, com o livre que estamos lendo
# tamanho temporario, conforme encontrar USO = 0 adicionar ao tamanho temporario, quando encontrar um USO = 1
    # seta o tamanho do bloco original
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rbx
    subq $16, %rbx # Seta flag de uso do bloco como livre 
    movq $0, (%rbx)

    # Ajusta os blocos livres

    popq %rbp
    ret



print_heap:
# Imprime o estado atual da memória
# Percorre a heap, imprimindo o estado de cada bloco

    pushq %rbp
    movq %rsp, %rbp


    movq BRK_ATUAL, %rax
    movq BRK_INICIAL, %rbx

        

    call printf

    popq %rbp
    ret
