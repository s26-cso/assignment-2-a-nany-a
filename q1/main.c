#include <stdio.h>

struct Node {
    int val;
    struct Node* left;
    struct Node* right;
};

struct Node* make_node(int val);
struct Node* insert(struct Node* root, int val);
struct Node* get(struct Node* root, int val);
int getAtMost(int val, struct Node* root);


void inorder(struct Node* root) {
    if (!root) return;
    inorder(root->left);
    printf("%d ", root->val);
    inorder(root->right);
}

int main() {
  
struct Node* root = NULL;

root = NULL;
int arr[] = {37, 12, 89, 45, 23, 78, 56, 90, 11, 67};

for (int i = 0; i < 10; i++)
    root = insert(root, arr[i]);

inorder(root);
    return 0;
}