    .section .text

    .irp sym, exit, read, write
        .global sys_\sym
    .endr

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
