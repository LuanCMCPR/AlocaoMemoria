.section .data
    HEAP_START: .quad 0
    HEAP_END: .quad 0


.section .text
.global _start

setup_brk: 
movq $12, %rax

dismiss_brk:

memory_alloc:

memory_free:

_start:
