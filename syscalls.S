    .include "macros.S"

    .section .text
    declare_global_v sys_exit, sys_read, sys_write

sys_exit:
    mov rax, 60
    syscall

sys_read:
    mov rax, 0
    syscall
    ret

sys_write:
    mov rax, 1
    syscall
    ret
