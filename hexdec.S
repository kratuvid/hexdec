    .section .rodata

str_help: .ascii "\033[1mhexdec\033[0m: "
          .incbin "help.txt"
    .equiv len_str_help, (. - str_help)
str_stack_imbalance: .ascii "Developer error: stack isn't balanced at exit"
    .equiv len_str_stack_imbalance, (. - str_stack_imbalance)

str_base_bin: .ascii "01"
str_base_oct: .ascii "01234567"
str_base_dec: .ascii "0123456789"
str_base_hex: .ascii "0123456789abcdef"

    # Current (i)nput and (o)utput base configuration
    .lcomm str_ibase, 8
    .lcomm str_obase, 8
    .lcomm size_ibase, 8
    .lcomm size_obase, 8


    .section .text
    .global _start

_start:
    mov rbp, rsp

    mov rdi, rbp
    call handle_args

    mov rdi, rbp
    mov rsi, rsp
    call verify_stack_balance

    mov rdi, 0
    jmp sys_exit

# Changes the current configuration or exits furiously if needed
handle_args:    # (base stack pointer of _start)
    ret

# Quit after displaying the help menu
quit_help:
    mov rdi, 2
    lea rsi, str_help[rip]
    mov rdx, len_str_help
    call sys_write

    mov rdi, 1
    jmp sys_exit

# Checks if stack variables were properly released aka is rsp == rbp?
verify_stack_balance:   # (base stack pointer, stack pointer)
    cmp rdi, rsi
    je 0f

    mov rdi, 2
    lea rsi, str_stack_imbalance[rip]
    mov rdx, len_str_stack_imbalance
    call sys_write

    mov rdi, 1
    jmp sys_exit

    0:
    ret
