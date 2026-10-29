#Githup : AWM-ENG
.intel_syntax noprefix
.text

        #main
.global _start
_start:
    mov rax, [rsp]
    cmp rax, 3
    je uni_op
    cmp rax, 4
    je binr_op
    jmp wrong_op



        #reading input from command line arguments

        #unari operetors
uni_op:
    mov rdi, [rsp + 24]
    call atoi
    mov r11, rax
    mov rdi, [rsp + 16]
    cmp byte ptr [rdi], 0x2d
    je op_neg
    cmp byte ptr [rdi], 0x7e
    je op_not
    jmp wrong_op


        #binary operators
binr_op:
    mov rdi, [rsp + 16] 
    call atoi
    mov r11, rax
    mov rdi, [rsp + 32]                
    call atoi

    mov rdi, [rsp + 24]
    cmp byte ptr [rdi], 0x2b
    je op_add
    cmp byte ptr [rdi], 0x2d
    je op_sub
    cmp byte ptr [rdi], 0x2a
    je op_imul
    cmp byte ptr [rdi], 0x26
    je op_and
    cmp byte ptr [rdi], 0x7c
    je op_or
    cmp byte ptr [rdi], 0x5e
    je op_xor
    jmp wrong_op


        #reading input from stdin
op_add:
    add r11, rax
    jmp write_output

op_sub:
    sub r11, rax
    jmp write_output

op_imul:
    imul r11, rax
    jmp write_output

op_and:
    and r11, rax
    jmp write_output

op_or:
    or r11, rax
    jmp write_output

op_xor:
    xor r11, rax
    jmp write_output

op_neg:
    neg r11
    jmp write_output

op_not:
    not r11
    jmp write_output


        #writing output to stdout
write_output:
    sub rsp, 0x80            
    mov rdi, r11
    mov rsi, rsp           
    call itoa
    mov rdx, rax           
    mov rax, 1             
    mov rdi, 1                         
    mov rsi, rsp           
    syscall
    add rsp, 0x80           
    
        #end the program
    mov rdi, 0
    mov rax, 60
    syscall

wrong_op:
    mov rdi, 42
    mov rax, 60
    syscall


#-------------------------------------------------------------------------------------#
        #shared functions

        #convert a single digit character to its integer value
atoi_digit:
    movzx rax, byte ptr [rdi]
    sub rax, 0x30
    ret

        #convert a string to an integer
.global atoi
atoi:
    xor r8, r8
    xor rcx, rcx
    cmp byte ptr [rdi], 0x2d
    je atoi_neg
    mov rsi, rdi

atoi_loop:
    mov rdi, rsi 
    call atoi_digit
    cmp rax, 9
    ja atoi_end
    imul r8, 10
    add r8, rax
    inc rsi
    jmp atoi_loop

        #handle negative numbers
atoi_neg:
    mov rcx, 1
    inc rdi 
    mov rsi, rdi
    jmp atoi_loop

atoi_end:
    mov rax, r8
    cmp rcx, 1
    jne atoi_end1
    neg rax
    ret
          
atoi_end1:
    ret


        #convert a single digit integer to its character representation
.global itoa_digit 
itoa_digit:
    mov rax, rdi
    add rax, 0x30
    ret
        
        #convert an integer to a string
.global itoa 
itoa:
    xor rcx, rcx
    xor r10, r10
    test rdi, rdi
    jz itoa_end1
    cmp rdi, 0
    jl itoa_neg

itoa_back:
    xor r8, r8
    mov r9, 10
    mov rax, rdi

itoa_loop:
    xor rdx, rdx
    cmp rax, 0
    je itoa_loop2
    div r9
    push rdx
    inc rcx
    jmp itoa_loop

itoa_loop2:
    cmp r8, rcx
    je itoa_end
    pop rdx
    add rdx, 0x30
    mov byte ptr [rsi + r8], dl
    inc r8
    jmp itoa_loop2

itoa_end:
    add rcx, r10
    mov rax, rcx
    ret

itoa_end1:
    mov rax, 1
    mov byte ptr [rsi], 0x30
    ret

itoa_neg:
    mov byte ptr [rsi], 0x2d
    neg rdi
    mov r10, 1
    add rsi, 1
    jmp itoa_back



