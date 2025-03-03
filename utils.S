    .include "macros.S"

    .section .text
    declare_global_v tonumber_dec, strcmp, strlen, display_str, dev_quit_error

tonumber_dec:   # (string, length of string)
    xor r8, r8

    dec rsi
    mov rcx, 1

    .L1_loop:
    cmp rsi, 0
    jl .L1_end

    xor rax, rax
    mov al, [rdi + rsi]
    sub al, 48  # 48 is ASCII for '0'
    mul rcx
    add r8, rax

    mov rdx, 10
    mov rax, rcx
    mul rdx
    mov rcx, rax

    dec rsi
    jmp .L1_loop

    .L1_end:
    mov rax, r8
    ret

# ret: 0 if equal, otherwise 1
strcmp:     # (first string, second string)
    xor rax, rax
    mov rcx, 0

    0:
    mov r8b, [rdi + rcx]
    mov r9b, [rsi + rcx]

    cmp r8b, r9b
    jne 1f

    cmp r8b, 0
    je 2f

    inc rcx
    jmp 0b

    1:
    mov rax, 1

    2:
    ret

strlen:     # (address of null-terminated string)
    mov rax, rdi

    0:
    inc rax
    cmp byte ptr [rax-1], 0
    jne 0b

    sub rax, rdi
    dec rax

    ret

display_str:    # (file descriptor, address of null-terminated string, display newline?)
    push_v rdi, rsi, rdx
    mov rdi, rsi
    call strlen
    pop_v rdx, rsi, rdi

    cmp rdx, 0
    mov rdx, rax
    je 1f

    mov byte ptr [rsi + rax], '\n'
    inc rdx

    1:
    call sys_write

    ret

# write rdi to stderr and exit
dev_quit_error:
    push rdi
    mov rdi, 2
    mov rsi, rsp
    mov rdx, 8
    call sys_write

    mov rdi, 2
    jmp sys_exit
