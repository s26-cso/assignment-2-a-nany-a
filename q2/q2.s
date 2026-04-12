# a0 = argc
# a1 = argv

.global main
main:
addi sp, sp, -64
sd ra, 0(sp)
sd s1, 8(sp) # s1 will point to the answer array that i am going to output
sd s2, 16(sp) # s2 will point to the stack
sd s3, 32(sp) # s3 will be the top=-1
sd s0, 24(sp) # size of array
sd s5, 48(sp) # a register i am going to use bedore loop 2 to store some stuff

addi a1, a1, 8  # to skip the ./a thing and make a1 point to the array
sd a1, 40(sp)
addi s0, a0, -1 # size of array

slli a0, s0, 3 # allocate space to answer array
call malloc
addi s1, a0, 0 

slli a0, s0, 3 # allocate space to stack
call malloc
addi s2, a0, 0  

addi a0, x0, 8 # allocate space to top
call malloc
addi s3, a0, 0 
addi s3, x0, -1

addi t1, s0, -1  # present index of array i am on
sd t1, 56(sp)

addi t3, x0, 0
loop1:  # to fill the ans array with -1
beq t3, s0, loop
slli t2, t3, 3
add t2, t2, s1
addi t4, x0, -1
sd t4, 0(t2)
addi t3, t3, 1
j loop1

loop:
blt t1, x0, exit
addi t3, x0, 8
mul t2, t1, t3
ld a1, 40(sp)
add t3, a1, t2 
ld t3, 0(t3)

add a0, t3, x0
call atoi  # to change it from a string to int a0 now has ele of array as int
ld t1, 56(sp)

addi s5, a0, 0 # s5 now has the value of the present element of array
loop2:
addi t2, x0, -1
beq s3, t2, break # stack empty
slli t2, s3, 3
add t2, s2, t2 
ld t3, 0(t2) # t3 now has stack top
slli t3, t3, 3
ld a1, 40(sp)
add t3, t3, a1
ld t3, 0(t3)
# addi s5, a0, 0
addi a0, t3, 0 # a0 now contains the element from array whose index is stack[top]
sd t1, 56(sp)
call atoi
ld t1, 56(sp)
bgt a0, s5, break 
addi s3, s3, -1
j loop2

break:
addi t2, x0, -1
beq s3, t2, continue

result:
slli t2, t1, 3
add t2, t2, s1
slli t3, s3, 3
add t3, s2, t3
ld t3, 0(t3)
sd t3, 0(t2)

continue:
addi s3, s3, 1
slli t2, s3, 3
add t2, s2, t2 
sd t1, 0(t2) # push index of current array ele into stack

addi t1, t1, -1
sd t1, 56(sp)
j loop

exit:

addi t3, x0, 0 # initiate the loop i = 0
addi s0, s0, -1
print:
beq t3, s0, stop # if i = n-1 stop
slli t2, t3, 3
add t2, t2, s1
ld a1, 0(t2)  # a1 = ans[i]
la a0, fmt  # format string "%ld "
sd t3, 56(sp) # to save i before call printf
call printf
ld t3, 56(sp) # get i back 
addi t3, t3, 1
j print

stop:
slli t2, t3, 3
add t2, t2, s1
ld a1, 0(t2)  # a1 = ans[i]
la a0, fmt2  # format string "%ld"
call printf
li a0, '\n'
call putchar 
li a0, 0
ld ra, 0(sp)
ld s1, 8(sp) 
ld s2, 16(sp) 
ld s3, 32(sp)
ld s0, 24(sp)
ld s5, 48(sp)
addi sp, sp, 64
ret

.section .rodata
fmt: .string "%ld "
fmt2: .string "%ld"