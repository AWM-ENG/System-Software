#Githup : AWM-ENG

.intel_syntax noprefix
.text

        #main
.global _start
_start:
    xor r11, r11         
    mov r12, 16           

        #reading input from stdin
read_loop:
    mov rdi, [rsp + r12]   
    test rdi, rdi
    jz write_output
    call atoi
    add r11, rax
    add r12, 8
    jmp read_loop

        #writing output to stdout
write_output:
    sub rsp, 64            
    mov rdi, r11
    mov rsi, rsp           
    call itoa
    mov rdx, rax           
    mov rax, 1             
    mov rdi, 1                         
    mov rsi, rsp           
    syscall
    add rsp, 64           
    
        #end the program
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
