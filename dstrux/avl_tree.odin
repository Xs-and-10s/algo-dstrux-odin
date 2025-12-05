package dstrux

import "core:mem"

// AVLNode represents a node in an AVL tree
AVLNode :: struct($T: typeid) {
    value: T,
    left: ^AVLNode(T),
    right: ^AVLNode(T),
    height: int,
}

// AVLTree is a self-balancing binary search tree
AVLTree :: struct($T: typeid) {
    root: ^AVLNode(T),
    size: int,
    allocator: mem.Allocator,
}

// avl_make creates a new AVLTree
avl_make :: proc($T: typeid, allocator := context.allocator) -> AVLTree(T) {
    return AVLTree(T) {
        root = nil,
        size = 0,
        allocator = allocator,
    }
}

// avl_destroy frees the AVLTree
avl_destroy :: proc(tree: ^AVLTree($T)) {
    _avl_destroy_node(tree, tree.root)
    tree.root = nil
    tree.size = 0
}

_avl_destroy_node :: proc(tree: ^AVLTree($T), node: ^AVLNode(T)) {
    if node == nil do return
    _avl_destroy_node(tree, node.left)
    _avl_destroy_node(tree, node.right)
    free(node, tree.allocator)
}

// avl_height returns the height of a node
_avl_height :: proc(node: ^AVLNode($T)) -> int {
    if node == nil do return 0
    return node.height
}

// avl_update_height updates the height of a node
_avl_update_height :: proc(node: ^AVLNode($T)) {
    node.height = 1 + max(_avl_height(node.left), _avl_height(node.right))
}

// avl_balance_factor returns the balance factor of a node
_avl_balance_factor :: proc(node: ^AVLNode($T)) -> int {
    if node == nil do return 0
    return _avl_height(node.left) - _avl_height(node.right)
}

// avl_rotate_right performs a right rotation
_avl_rotate_right :: proc(y: ^AVLNode($T)) -> ^AVLNode(T) {
    x := y.left
    t2 := x.right

    x.right = y
    y.left = t2

    _avl_update_height(y)
    _avl_update_height(x)

    return x
}

// avl_rotate_left performs a left rotation
_avl_rotate_left :: proc(x: ^AVLNode($T)) -> ^AVLNode(T) {
    y := x.right
    t2 := y.left

    y.left = x
    x.right = t2

    _avl_update_height(x)
    _avl_update_height(y)

    return y
}

// avl_insert adds a value to the tree
avl_insert :: proc(tree: ^AVLTree($T), value: T) where T: ordered {
    tree.root = _avl_insert_node(tree, tree.root, value)
}

_avl_insert_node :: proc(tree: ^AVLTree($T), node: ^AVLNode(T), value: T) -> ^AVLNode(T) where T: ordered {
    if node == nil {
        new_node := new(AVLNode(T), tree.allocator)
        new_node.value = value
        new_node.left = nil
        new_node.right = nil
        new_node.height = 1
        tree.size += 1
        return new_node
    }

    if value < node.value {
        node.left = _avl_insert_node(tree, node.left, value)
    } else if value > node.value {
        node.right = _avl_insert_node(tree, node.right, value)
    } else {
        return node // No duplicates
    }

    _avl_update_height(node)

    // Balance the node
    balance := _avl_balance_factor(node)

    // Left-Left case
    if balance > 1 && value < node.left.value {
        return _avl_rotate_right(node)
    }

    // Right-Right case
    if balance < -1 && value > node.right.value {
        return _avl_rotate_left(node)
    }

    // Left-Right case
    if balance > 1 && value > node.left.value {
        node.left = _avl_rotate_left(node.left)
        return _avl_rotate_right(node)
    }

    // Right-Left case
    if balance < -1 && value < node.right.value {
        node.right = _avl_rotate_right(node.right)
        return _avl_rotate_left(node)
    }

    return node
}

// avl_search searches for a value in the tree
avl_search :: proc(tree: ^AVLTree($T), value: T) -> bool where T: ordered {
    return _avl_search_node(tree.root, value)
}

_avl_search_node :: proc(node: ^AVLNode($T), value: T) -> bool where T: ordered {
    if node == nil do return false

    if value == node.value {
        return true
    } else if value < node.value {
        return _avl_search_node(node.left, value)
    } else {
        return _avl_search_node(node.right, value)
    }
}

// avl_remove removes a value from the tree
avl_remove :: proc(tree: ^AVLTree($T), value: T) -> bool where T: ordered {
    old_size := tree.size
    tree.root = _avl_remove_node(tree, tree.root, value)
    return tree.size < old_size
}

_avl_remove_node :: proc(tree: ^AVLTree($T), node: ^AVLNode(T), value: T) -> ^AVLNode(T) where T: ordered {
    if node == nil do return nil

    if value < node.value {
        node.left = _avl_remove_node(tree, node.left, value)
    } else if value > node.value {
        node.right = _avl_remove_node(tree, node.right, value)
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
            // Node has two children
            successor := _avl_find_min(node.right)
            node.value = successor.value
            node.right = _avl_remove_node(tree, node.right, successor.value)
        }
    }

    if node == nil do return nil

    _avl_update_height(node)

    // Balance the node
    balance := _avl_balance_factor(node)

    // Left-Left case
    if balance > 1 && _avl_balance_factor(node.left) >= 0 {
        return _avl_rotate_right(node)
    }

    // Left-Right case
    if balance > 1 && _avl_balance_factor(node.left) < 0 {
        node.left = _avl_rotate_left(node.left)
        return _avl_rotate_right(node)
    }

    // Right-Right case
    if balance < -1 && _avl_balance_factor(node.right) <= 0 {
        return _avl_rotate_left(node)
    }

    // Right-Left case
    if balance < -1 && _avl_balance_factor(node.right) > 0 {
        node.right = _avl_rotate_right(node.right)
        return _avl_rotate_left(node)
    }

    return node
}

_avl_find_min :: proc(node: ^AVLNode($T)) -> ^AVLNode(T) {
    current := node
    for current.left != nil {
        current = current.left
    }
    return current
}

// avl_len returns the number of nodes
avl_len :: proc(tree: ^AVLTree($T)) -> int {
    return tree.size
}

// avl_is_empty checks if the tree is empty
avl_is_empty :: proc(tree: ^AVLTree($T)) -> bool {
    return tree.root == nil
}

// avl_height returns the height of the tree
avl_height :: proc(tree: ^AVLTree($T)) -> int {
    return _avl_height(tree.root)
}
