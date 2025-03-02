    .section .rodata

str_help:
    .ascii "\033[1mhexdec\033[0m: "
    .incbin "help.txt"
.equiv len_str_help, (. - str_help)

    .section .text
    .global _start

_start:
    mov rdi, 1
    lea rsi, str_help[rip]
    mov rdx, len_str_help
    call sys_write

    mov rdi, 23
    jmp sys_exit
