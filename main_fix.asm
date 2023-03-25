    bits 64
    extern malloc, free, puts, printf, fflush, abort
    global main

    section   .data
empty_str: db 0x0
int_format: db "%ld ", 0x0
data: dq 4, 8, 15, 16, 23, 42
data_length: equ ($-data) / 8

    section   .text
;;; print_int proc
print_int:
    mov rsi, [rdi]
    mov rdi, int_format
    xor rax, rax
    call printf

    xor rdi, rdi
    call fflush

    ret


;--- fix memory leaks ---

del_element:
    call free

    ret

;------------------------


;;; p proc
p:
    mov rax, rdi
    and rax, 1
    ret

;;; add_element proc
add_element:
    push rbp
    push rbx

    mov rbp, rdi
    mov rbx, rsi

    mov rdi, 16
    call malloc
    test rax, rax
    jz abort

    mov [rax], rbp
    mov [rax + 8], rbx

    pop rbx
    pop rbp

    ret

;------------------------
m:
    push rbp
    push r12
    push r13
    
    mov  r12, rsi
    test rdi, rdi
    je   .exit
    
    .loop:
    mov  r13, [rdi+8]
    call r12            
    mov  rdi, r13
    test r13, r13
    jne  .loop

    .exit:
    pop r13
    pop r12
    pop rbp
    ret
;------------------------

;;; f proc
f:
    mov rax, rsi

    test rdi, rdi
    jz outf

    push rbx
    push r12
    push r13

    mov rbx, rdi
    mov r12, rsi
    mov r13, rdx

    mov rdi, [rdi]
    call rdx
    test rax, rax
    jz z

    mov rdi, [rbx]
    mov rsi, r12
    call add_element
    mov rsi, rax
    jmp ff

z:
    mov rsi, r12

ff:
    mov rdi, [rbx + 8]
    mov rdx, r13
    call f

    pop r13
    pop r12
    pop rbx

outf:
    ret

;;; main proc
main:
    push rbx

    xor rax, rax
    mov rbx, data_length
adding_loop:
    mov rdi, [data - 8 + rbx * 8]
    mov rsi, rax
    call add_element
    dec rbx
    jnz adding_loop

    mov rbx, rax

    mov r12, rax        ; fix: save pointer to delete
    push r12
    mov rdi, r12
    mov rsi, print_int
    call m

    mov rdi, empty_str
    call puts


    mov rdx, p
    xor rsi, rsi
    mov rdi, rbx
    call f

    mov r13, rax        ; fix: save pointer to delete
    push r13
    mov rdi, r13
    mov rsi, print_int
    call m

    mov rdi, empty_str
    call puts


;--- fix memory leaks ---

    pop r13
    mov rdi, r13
    mov rsi, del_element
    call m

    pop r12
    mov rdi, r12
    mov rsi, del_element
    call m

;------------------------


    pop rbx

    xor rax, rax
    ret
