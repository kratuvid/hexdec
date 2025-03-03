    .include "macros.S"

    .section .rodata

str_help: .ascii "\033[1mhexdec\033[0m: "
          .incbin "help.txt"
    .equiv len_str_help, (. - str_help)
str_stack_imbalance: .ascii "Developer error: stack isn't balanced at exit\n"
    .equiv len_str_stack_imbalance, (. - str_stack_imbalance)
str_no_options: .ascii "Error: give all the required options\n"
    .equiv len_str_no_options, (. - str_no_options)
str_argument_absent: .ascii "Error: missing argument for an option\n"
    .equiv len_str_argument_absent, (. - str_argument_absent)
str_unknown_option: .ascii "Error: unknown option\n"
    .equiv len_str_unknown_option, (. - str_unknown_option)
str_size_mismatch: .ascii "Error: alphabet and base mismatch\n"
    .equiv len_str_size_mismatch, (. - str_size_mismatch)
str_size_zero: .ascii "Error: base size is zero\n"
    .equiv len_str_size_zero, (. - str_size_zero)
str_option_help: .asciz "--help"
str_option_ibase: .asciz "--ibase"
str_option_obase: .asciz "--obase"
str_option_ialpha: .asciz "--ialpha"
str_option_oalpha: .asciz "--oalpha"

str_alpha_bin: .ascii "01"
str_alpha_oct: .ascii "01234567"
str_alpha_dec: .ascii "0123456789"
str_alpha_hex: .ascii "0123456789abcdef"

    # Current (i)nput and (o)utput base configuration
    .lcomm quad_ibase, 8
    .lcomm quad_obase, 8
    .lcomm str_ialpha, 8
    .lcomm str_oalpha, 8


    .section .text
    .global _start

_start:
    mov rbp, rsp

    mov rdi, [rbp]
    lea rsi, [rbp + 8]
    call handle_args

    mov rdi, rbp
    mov rsi, rsp
    call verify_stack_balance

    mov rdi, 0
    jmp sys_exit

# Changes the current configuration or exits furiously on error
handle_args:    # (argc, argv)
    push rbp
    mov rbp, rsp

    # --argc and skip argv[0]
    dec rdi
    jz .L1_error_no_options
    add rsi, 8

    .L1_loop:

    # --help
    .macro cmp_arg str
        push_v rsi
        mov rdi, [rsi]
        lea rsi, \str[rip]
        call strcmp
        pop_v rsi
    .endm

    cmp_arg str_option_help
    test rax, rax
    jz quit_help

    # --ialpha and --oalpha
    cmp_arg str_option_ialpha
    test rax, rax
    jz .L1_ialpha

    cmp_arg str_option_oalpha
    test rax, rax
    jz .L1_oalpha

    # --ibase and --obase
    cmp_arg str_option_ibase
    test rax, rax
    jz .L1_ibase

    cmp_arg str_option_obase
    test rax, rax
    jz .L1_obase

    # unknown argument
    jmp .L1_error_unknown_option

    .L1_switch_end:
    add rsi, 8
    cmp qword ptr [rsi], 0
    jne .L1_loop

    # check if all requirements were met
    # verify each of them were filled
    .irp ptr, str_ialpha, str_oalpha, quad_ibase, quad_obase
        # jumps to error pathway if any of them is zero
        mov rax, \ptr[rip]
        test rax, rax
        jz .L1_error_no_options
    .endr

    # check sizes
    push_v r12, r13
    mov r12, qword ptr quad_ibase[rip]
    mov r13, qword ptr quad_obase[rip]

    cmp r12, 0
    je .L1_error_size_zero
    cmp r13, 0
    je .L1_error_size_zero

    mov rdi, str_ialpha[rip]
    call strlen
    cmp r12, rax
    jne .L1_error_size_mismatch

    mov rdi, str_oalpha[rip]
    call strlen
    cmp r13, rax
    jne .L1_error_size_mismatch

    pop_v r13, r12
    
    # success!
    jmp .L1_success

    # switch case handlers
    .macro .L1m_alpha_routine str
        cmp qword ptr [rsi + 8], 0
        je .L1_error_argument_absent

        add rsi, 8

        mov rax, [rsi]
        mov \str[rip], rax
    .endm

    .L1_ialpha:
    .L1m_alpha_routine str_ialpha
    jmp .L1_switch_end

    .L1_oalpha:
    .L1m_alpha_routine str_oalpha
    jmp .L1_switch_end

    .macro .L1m_base_routine quad
        cmp qword ptr [rsi + 8], 0
        je .L1_error_argument_absent

        add rsi, 8

        push rsi
        mov rdi, [rsi]
        call strlen
        pop rsi

        push rsi
        mov rdi, [rsi]
        mov rsi, rax
        call tonumber_dec
        mov \quad[rip], rax
        pop rsi
    .endm

    .L1_ibase:
    .L1m_base_routine quad_ibase
    jmp .L1_switch_end

    .L1_obase:
    .L1m_base_routine quad_obase
    jmp .L1_switch_end

    # |error pathways
    .macro .L1m_error_routine str
        mov rdi, 2
        lea rsi, \str[rip]
        mov rdx, len_\str
        call sys_write

        mov rdi, 1
        jmp sys_exit
    .endm

    .L1_error_size_mismatch:
    .L1m_error_routine str_size_mismatch

    .L1_error_size_zero:
    .L1m_error_routine str_size_zero

    .L1_error_no_options:
    .L1m_error_routine str_no_options
    
    .L1_error_argument_absent:
    .L1m_error_routine str_argument_absent

    .L1_error_unknown_option:
    .L1m_error_routine str_unknown_option

    # success pathway
    .L1_success:
    pop rbp
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
