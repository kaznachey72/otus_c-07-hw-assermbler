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

;--- m proc -------------
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

;--- f proc -------------

f:
    push r15
    push r14
    push r13
    mov  r13, rdi   ; iput
    mov  r14, rsi   ; oput
    mov  r15, rdx   ; pred

    test r13, r13
    je .exit

    .loop_cond:
        mov  rdi, [r13]
        call r15
        test rax, rax
        jne  .pred_cond
        
        mov  r13, [r13+8]
        test r13, r13
        jne  .loop_cond
        jmp  .exit

    .pred_cond:
        mov  rdi, [r13]
        mov  rsi, r14
        call add_element
        
        mov  r13, [r13+8]
        mov  r14, rax
        test r13, r13
        jne  .loop_cond
    
    .exit:
        mov rax, r14
        pop r13
        pop r14
        pop r15
        ret

;------------------------

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
