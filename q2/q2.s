# Struct Node layout on riscv64 (pointers = 8 bytes):
# offset  0: int val       (4 bytes)
# offset  4: padding       (4 bytes, inserted by C compiler for alignment)
# offset  8: Node* left    (8 bytes)
# offset 16: Node* right   (8 bytes)
# sizeof(Node) = 24  <-- NOT 12!

# ---------------------------------------------------------------
# struct Node* make_node(int val)
# a0 = val (int)
# Returns: a0 = pointer to new node
# ---------------------------------------------------------------
.global make_node
make_node:
    addi sp, sp, -16
    sd   ra, 0(sp)         # save return address (8 bytes)
    sw   a0, 8(sp)         # save val (int, 4 bytes)

    li   a0, 24            # sizeof(struct Node) = 24, NOT 12
    call malloc

    lw   t0, 8(sp)         # reload val
    sw   t0,  0(a0)        # node->val   = val   (int, sw is correct)
    sd   zero, 8(a0)       # node->left  = NULL  (pointer, sd for 8 bytes)
    sd   zero, 16(a0)      # node->right = NULL  (pointer, sd for 8 bytes)
    # a0 already holds the new node pointer -- return it

    ld   ra, 0(sp)
    addi sp, sp, 16
    ret

# ---------------------------------------------------------------
# struct Node* insert(struct Node* root, int val)
# a0 = root (pointer, 8 bytes), a1 = val (int, 4 bytes)
# Returns: a0 = root of updated tree
# ---------------------------------------------------------------
.global insert
insert:
    # Base case: root is NULL, just create a new node
    beq  a0, zero, insert_null

    # Build stack frame: need to save ra, root pointer, and val
    # ra   @ sp+0  (8 bytes)
    # root @ sp+8  (8 bytes -- pointer!)
    # val  @ sp+16 (4 bytes -- int, padded to 8 for alignment)
    addi sp, sp, -32
    sd   ra,  0(sp)
    sd   a0,  8(sp)        # save root pointer with sd (8-byte pointer)
    sw   a1, 16(sp)        # save val with sw (4-byte int)

    lw   t0, 0(a0)         # t0 = root->val (int, lw is correct)
    blt  a1, t0, insert_left
    beq  a1, t0, insert_dup  # duplicate value: return root unchanged

insert_right:
    ld   a0, 16(a0)        # a0 = root->right  (ld for 8-byte pointer, offset 16!)
    lw   a1, 16(sp)        # reload val
    call insert
    ld   t1,  8(sp)        # t1 = saved root pointer
    sd   a0, 16(t1)        # root->right = returned subtree root  (sd, offset 16!)
    ld   a0,  8(sp)        # return original root
    j    insert_exit

insert_left:
    ld   a0,  8(a0)        # a0 = root->left   (ld for 8-byte pointer, offset 8!)
    lw   a1, 16(sp)        # reload val
    call insert
    ld   t1,  8(sp)        # t1 = saved root pointer
    sd   a0,  8(t1)        # root->left = returned subtree root   (sd, offset 8!)
    ld   a0,  8(sp)        # return original root
    j    insert_exit

insert_dup:
    ld   a0, 8(sp)         # return root unchanged

insert_exit:
    ld   ra, 0(sp)
    addi sp, sp, 32
    ret

insert_null:
    # root == NULL: tail-call make_node(val)
    # ra is still caller's ra (we haven't touched sp), so make_node
    # will return directly to insert's caller. a1 has val, move to a0.
    mv   a0, a1
    tail make_node

# ---------------------------------------------------------------
# struct Node* get(struct Node* root, int val)
# a0 = root (pointer), a1 = val (int)
# Returns: a0 = pointer to matching node, or NULL
# Iterative (no stack frame needed)
# ---------------------------------------------------------------
.global get
get:
    beq  a0, zero, get_done   # NULL root -> return NULL
    lw   t0, 0(a0)            # t0 = node->val
    beq  a1, t0, get_done     # found it -> return a0
    blt  a1, t0, get_left

get_right:
    ld   a0, 16(a0)           # a0 = node->right  (offset 16!)
    j    get

get_left:
    ld   a0,  8(a0)           # a0 = node->left   (offset 8!)
    j    get

get_done:
    ret

# ---------------------------------------------------------------
# int getAtMost(int val, struct Node* root)
# a0 = val (int), a1 = root (pointer)
# Returns: a0 = greatest value in tree <= val, or -1
# Iterative (no stack frame needed)
# ---------------------------------------------------------------
.global getAtMost
getAtMost:
    li   t5, -1               # t5 = best answer so far

getAtMost_loop:
    beq  a1, zero, getAtMost_done
    lw   t0, 0(a1)            # t0 = node->val
    blt  a0, t0, getAtMost_left  # val < node->val -> go left (no update)

    # val >= node->val: this node is a valid candidate, record it and go right
    mv   t5, t0
    ld   a1, 16(a1)           # a1 = node->right  (offset 16!)
    j    getAtMost_loop

getAtMost_left:
    ld   a1,  8(a1)           # a1 = node->left   (offset 8!)
    j    getAtMost_loop

getAtMost_done:
    mv   a0, t5
    ret