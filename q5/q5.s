.section .data
name: .asciz "input.txt"
mode: .asciz "r"

.section .text
.global main
main:
addi sp, sp, -16
sd ra, 0(sp)
la a0, name
la a1, mode
call fopen 
addi s0, a0, 0 # s0 is now a pointer to my file
# fseek(fptr,0,SEEK_END);
addi a0, s0, 0
li a1, 0
li a2, 2 # SEEK_END has a constant value of 2 
call fseek # fseek gives me freedom to randomly access any element fron the file
addi a0, s0, 0 # s0 at end of string  

call ftell # to return the pos of s0 = string size
addi s1, a0, 0 # s1 contains size

addi s5, x0, 0 # i=0 
loop:
slli t5, s5, 1
bge t5, s1, yes # entire string has been parsed

addi a0, s0, 0
add a1, x0, s5
li a2, 0 # SEEK_SET has a constant value of 0
call fseek

addi a0, s0, 0
call fgetc
addi t2, a0, 0

addi a0, s0, 0
sub a1, s1, s5
addi a1, a1, -1
li a2, 0 # SEEK_SET
call fseek

addi a0, s0, 0
call fgetc
addi t3, a0, 0

bne t2, t3, no
addi s5, s5, 1
j loop

no:
la a0, ans2
call printf
j exit

yes:
la a0, ans
call printf

exit:
mv a0, s0
call fclose
ld ra, 0(sp)
addi sp, sp, -16
ret

.section .rodata
ans:  .asciz "Yes\n"
ans2: .asciz "No\n"
