package dstrux

import "core:mem"

// BSTNode represents a node in a binary search tree
BSTNode :: struct($T: typeid) {
    value: T,
    left: ^BSTNode(T),
    right: ^BSTNode(T),
}

// BinarySearchTree is a binary search tree
BinarySearchTree :: struct($T: typeid) {
    root: ^BSTNode(T),
    size: int,
    allocator: mem.Allocator,
}

// bst_make creates a new BinarySearchTree
bst_make :: proc($T: typeid, allocator := context.allocator) -> BinarySearchTree(T) {
    return BinarySearchTree(T) {
        root = nil,
        size = 0,
        allocator = allocator,
    }
}

// bst_destroy frees the BinarySearchTree
bst_destroy :: proc(tree: ^BinarySearchTree($T)) {
    _bst_destroy_node(tree, tree.root)
    tree.root = nil
    tree.size = 0
}

_bst_destroy_node :: proc(tree: ^BinarySearchTree($T), node: ^BSTNode(T)) {
    if node == nil do return
    _bst_destroy_node(tree, node.left)
    _bst_destroy_node(tree, node.right)
    free(node, tree.allocator)
}

// bst_insert adds a value to the tree
bst_insert :: proc(tree: ^BinarySearchTree($T), value: T) {
    tree.root = _bst_insert_node(tree, tree.root, value)
}

_bst_insert_node :: proc(tree: ^BinarySearchTree($T), node: ^BSTNode(T), value: T) -> ^BSTNode(T) {
    if node == nil {
        new_node := new(BSTNode(T), tree.allocator)
        new_node.value = value
        new_node.left = nil
        new_node.right = nil
        tree.size += 1
        return new_node
    }

    if value < node.value {
        node.left = _bst_insert_node(tree, node.left, value)
    } else if value > node.value {
        node.right = _bst_insert_node(tree, node.right, value)
    }
    // If value == node.value, do nothing (no duplicates)

    return node
}

// bst_search searches for a value in the tree
bst_search :: proc(tree: ^BinarySearchTree($T), value: T) -> bool {
    return _bst_search_node(tree.root, value)
}

_bst_search_node :: proc(node: ^BSTNode($T), value: T) -> bool {
    if node == nil do return false

    if value == node.value {
        return true
    } else if value < node.value {
        return _bst_search_node(node.left, value)
    } else {
        return _bst_search_node(node.right, value)
    }
}

// bst_remove removes a value from the tree
bst_remove :: proc(tree: ^BinarySearchTree($T), value: T) -> bool {
    old_size := tree.size
    tree.root = _bst_remove_node(tree, tree.root, value)
    return tree.size < old_size
}

_bst_remove_node :: proc(tree: ^BinarySearchTree($T), node: ^BSTNode(T), value: T) -> ^BSTNode(T) {
    if node == nil do return nil

    if value < node.value {
        node.left = _bst_remove_node(tree, node.left, value)
    } else if value > node.value {
        node.right = _bst_remove_node(tree, node.right, value)
    } else {
        // Found the node to remove
        if node.left == nil {
            right := node.right
            free(node, tree.allocator)
            tree.size -= 1
            return right
        } else if node.right == nil {
            left := node.left
            free(node, tree.allocator)
            tree.size -= 1
            return left
        } else {
            // Node has two children, find in-order successor
            successor := _bst_find_min(node.right)
            node.value = successor.value
            node.right = _bst_remove_node(tree, node.right, successor.value)
        }
    }

    return node
}

_bst_find_min :: proc(node: ^BSTNode($T)) -> ^BSTNode(T) {
    current := node
    for current.left != nil {
        current = current.left
    }
    return current
}

// bst_find_min_value finds the minimum value in the tree
bst_find_min_value :: proc(tree: ^BinarySearchTree($T)) -> (T, bool) {
    if tree.root == nil {
        return {}, false
    }
    node := _bst_find_min(tree.root)
    return node.value, true
}

// bst_find_max_value finds the maximum value in the tree
bst_find_max_value :: proc(tree: ^BinarySearchTree($T)) -> (T, bool) {
    if tree.root == nil {
        return {}, false
    }
    current := tree.root
    for current.right != nil {
        current = current.right
    }
    return current.value, true
}

// bst_len returns the number of nodes
bst_len :: proc(tree: ^BinarySearchTree($T)) -> int {
    return tree.size
}

// bst_is_empty checks if the tree is empty
bst_is_empty :: proc(tree: ^BinarySearchTree($T)) -> bool {
    return tree.root == nil
}

// bst_height returns the height of the tree
bst_height :: proc(tree: ^BinarySearchTree($T)) -> int {
    return _bst_height_node(tree.root)
}

_bst_height_node :: proc(node: ^BSTNode($T)) -> int {
    if node == nil do return 0
    left_height := _bst_height_node(node.left)
    right_height := _bst_height_node(node.right)
    return 1 + max(left_height, right_height)
}
