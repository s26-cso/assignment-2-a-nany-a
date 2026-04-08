# VAL- 0
# LEFT- 8
# RIGHT- 16

.global make_node 
make_node:

addi sp, sp, -16
sw a0, 0(sp) # to store the input val
sw ra, 8(sp) 
li a0, 24  # this is the size of the struct
call malloc 
addi t0, a0, 0 # t0 contains add of allocated memory
lw t5, 0(sp) # val is now loaded in t5
sw t5, 0(t0) # val stored
addi t4, x0, 0
sw t4, 8(t0) # left stored
sw t4, 16(t0) # right stored

addi a0, t0, 0
lw ra, 8(sp)
addi sp, sp, 16
ret


.global insert
insert:
addi sp, sp, -32
sw a0, 0(sp) # to store root
sw a1, 8(sp) # to store val
sw ra, 16(sp) 
beq a0, x0, insertNode
lw t1, 0(a0) # t1 has val of root node
blt a1, t1, leftchild
j rightchild

rightchild:
lw t2, 16(a0) # t2 now has the address of right child
addi a0, t2, 0 # now a0 has address of right child
lw a1, 8(sp)
call insert # use call as i need to return here after insert is done so I can join the subtree to the root
lw t3, 0(sp)
sw a0, 16(t3) # joining the node to the right subtree of root
lw a0, 0(sp)
j exit

leftchild:
lw t2, 8(a0) # t2 now has the add of left child
addi a0, t2, 0 # now a0 has add of left child
lw a1, 8(sp)
call insert
lw t3, 0(sp)
sw a0, 8(t3) # joining the node to the left subtree of root
lw a0, 0(sp)
j exit

insertNode:
addi a0, a1, 0
call make_node

exit:
lw ra, 16(sp)
addi sp, sp, 32
ret


.global get
get:
addi sp, sp, -32
sw a0, 0(sp) # to store add of root
sw a1, 8(sp)
sw ra, 16(sp) 
beq a0, x0, exit1
lw t0, 0(a0) # t0 now has value of root
beq t0, a1, exit1
blt a1, t0, left
bgt a1, t0, right

left:
lw a0, 8(a0) # 4(a0) has the value that is the address of leftchild
lw a1, 8(sp)
call get
j exit1

right:
lw a0, 16(a0)
lw a1, 8(sp)
call get
j exit1

exit1:
lw ra, 16(sp)
addi sp, sp, 32
ret

.global getAtMost
getAtMost:
addi t5, x0, -1 # t5 will store the ans
loop:
# a0 to store val
# a1 to store add of root

beq a1, x0, exit2
lw t0, 0(a1) # t0 now has the value of root
blt a0, t0, leftch
bge a0, t0, rightch # t0 is a valid choice for ans

leftch:
lw a1, 8(a1) # 4(a1) has the value that is the address of leftchild
j loop

rightch:
addi t5, t0, 0
lw a1, 16(a1)
j loop

exit2:
addi a0, t5, 0
ret
