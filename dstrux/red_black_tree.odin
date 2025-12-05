package dstrux

import "core:mem"

// RBColor represents the color of a Red-Black tree node
RBColor :: enum {
    Red,
    Black,
}

// RBNode represents a node in a Red-Black tree
RBNode :: struct($T: typeid) {
    value: T,
    color: RBColor,
    left: ^RBNode(T),
    right: ^RBNode(T),
    parent: ^RBNode(T),
}

// RedBlackTree is a self-balancing binary search tree
RedBlackTree :: struct($T: typeid) {
    root: ^RBNode(T),
    nil_node: ^RBNode(T), // Sentinel node
    size: int,
    allocator: mem.Allocator,
}

// rbt_make creates a new RedBlackTree
rbt_make :: proc($T: typeid, allocator := context.allocator) -> RedBlackTree(T) {
    nil_node := new(RBNode(T), allocator)
    nil_node.color = .Black
    nil_node.left = nil
    nil_node.right = nil
    nil_node.parent = nil

    return RedBlackTree(T) {
        root = nil_node,
        nil_node = nil_node,
        size = 0,
        allocator = allocator,
    }
}

// rbt_destroy frees the RedBlackTree
rbt_destroy :: proc(tree: ^RedBlackTree($T)) {
    _rbt_destroy_node(tree, tree.root)
    free(tree.nil_node, tree.allocator)
    tree.root = tree.nil_node
    tree.size = 0
}

_rbt_destroy_node :: proc(tree: ^RedBlackTree($T), node: ^RBNode(T)) {
    if node == tree.nil_node do return
    _rbt_destroy_node(tree, node.left)
    _rbt_destroy_node(tree, node.right)
    free(node, tree.allocator)
}

// rbt_rotate_left performs a left rotation
_rbt_rotate_left :: proc(tree: ^RedBlackTree($T), x: ^RBNode(T)) {
    y := x.right
    x.right = y.left

    if y.left != tree.nil_node {
        y.left.parent = x
    }

    y.parent = x.parent

    if x.parent == tree.nil_node {
        tree.root = y
    } else if x == x.parent.left {
        x.parent.left = y
    } else {
        x.parent.right = y
    }

    y.left = x
    x.parent = y
}

// rbt_rotate_right performs a right rotation
_rbt_rotate_right :: proc(tree: ^RedBlackTree($T), y: ^RBNode(T)) {
    x := y.left
    y.left = x.right

    if x.right != tree.nil_node {
        x.right.parent = y
    }

    x.parent = y.parent

    if y.parent == tree.nil_node {
        tree.root = x
    } else if y == y.parent.right {
        y.parent.right = x
    } else {
        y.parent.left = x
    }

    x.right = y
    y.parent = x
}

// rbt_insert adds a value to the tree
rbt_insert :: proc(tree: ^RedBlackTree($T), value: T) where T: ordered {
    node := new(RBNode(T), tree.allocator)
    node.value = value
    node.color = .Red
    node.left = tree.nil_node
    node.right = tree.nil_node
    node.parent = tree.nil_node

    y := tree.nil_node
    x := tree.root

    for x != tree.nil_node {
        y = x
        if node.value < x.value {
            x = x.left
        } else if node.value > x.value {
            x = x.right
        } else {
            // Duplicate value, free the node and return
            free(node, tree.allocator)
            return
        }
    }

    node.parent = y

    if y == tree.nil_node {
        tree.root = node
    } else if node.value < y.value {
        y.left = node
    } else {
        y.right = node
    }

    tree.size += 1
    _rbt_insert_fixup(tree, node)
}

_rbt_insert_fixup :: proc(tree: ^RedBlackTree($T), z: ^RBNode(T)) {
    node := z
    for node.parent.color == .Red {
        if node.parent == node.parent.parent.left {
            y := node.parent.parent.right
            if y.color == .Red {
                node.parent.color = .Black
                y.color = .Black
                node.parent.parent.color = .Red
                node = node.parent.parent
            } else {
                if node == node.parent.right {
                    node = node.parent
                    _rbt_rotate_left(tree, node)
                }
                node.parent.color = .Black
                node.parent.parent.color = .Red
                _rbt_rotate_right(tree, node.parent.parent)
            }
        } else {
            y := node.parent.parent.left
            if y.color == .Red {
                node.parent.color = .Black
                y.color = .Black
                node.parent.parent.color = .Red
                node = node.parent.parent
            } else {
                if node == node.parent.left {
                    node = node.parent
                    _rbt_rotate_right(tree, node)
                }
                node.parent.color = .Black
                node.parent.parent.color = .Red
                _rbt_rotate_left(tree, node.parent.parent)
            }
        }
    }
    tree.root.color = .Black
}

// rbt_search searches for a value in the tree
rbt_search :: proc(tree: ^RedBlackTree($T), value: T) -> bool where T: ordered {
    node := tree.root
    for node != tree.nil_node {
        if value == node.value {
            return true
        } else if value < node.value {
            node = node.left
        } else {
            node = node.right
        }
    }
    return false
}

// rbt_len returns the number of nodes
rbt_len :: proc(tree: ^RedBlackTree($T)) -> int {
    return tree.size
}

// rbt_is_empty checks if the tree is empty
rbt_is_empty :: proc(tree: ^RedBlackTree($T)) -> bool {
    return tree.root == tree.nil_node
}
