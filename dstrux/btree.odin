package dstrux

import "core:mem"

// BTreeNode represents a node in a B-tree
BTreeNode :: struct($T: typeid, $M: int) {
    keys: [M - 1]T,
    children: [M]^BTreeNode(T, M),
    num_keys: int,
    is_leaf: bool,
}

// BTree is a self-balancing tree optimized for disk access
BTree :: struct($T: typeid, $M: int) {
    root: ^BTreeNode(T, M),
    min_degree: int, // t (minimum degree)
    size: int,
    allocator: mem.Allocator,
}

// btree_make creates a new BTree
btree_make :: proc($T: typeid, $M: int, allocator := context.allocator) -> BTree(T, M) {
    root := new(BTreeNode(T, M), allocator)
    root.is_leaf = true
    root.num_keys = 0

    return BTree(T, M) {
        root = root,
        min_degree = (M + 1) / 2,
        size = 0,
        allocator = allocator,
    }
}

// btree_destroy frees the BTree
btree_destroy :: proc(tree: ^BTree($T, $M)) {
    _btree_destroy_node(tree, tree.root)
    tree.root = nil
    tree.size = 0
}

_btree_destroy_node :: proc(tree: ^BTree($T, $M), node: ^BTreeNode(T, M)) {
    if node == nil do return

    if !node.is_leaf {
        for i := 0; i <= node.num_keys; i += 1 {
            _btree_destroy_node(tree, node.children[i])
        }
    }

    free(node, tree.allocator)
}

// btree_search searches for a value in the tree
btree_search :: proc(tree: ^BTree($T, $M), value: T) -> bool {
    return _btree_search_node(tree.root, value)
}

_btree_search_node :: proc(node: ^BTreeNode($T, $M), value: T) -> bool {
    if node == nil do return false

    i := 0
    for i < node.num_keys && value > node.keys[i] {
        i += 1
    }

    if i < node.num_keys && value == node.keys[i] {
        return true
    }

    if node.is_leaf {
        return false
    }

    return _btree_search_node(node.children[i], value)
}

// btree_insert adds a value to the tree
btree_insert :: proc(tree: ^BTree($T, $M), value: T) {
    root := tree.root

    if root.num_keys == M - 1 {
        new_root := new(BTreeNode(T, M), tree.allocator)
        new_root.is_leaf = false
        new_root.num_keys = 0
        new_root.children[0] = root

        _btree_split_child(tree, new_root, 0)

        tree.root = new_root
        root = new_root
    }

    _btree_insert_non_full(tree, root, value)
    tree.size += 1
}

_btree_insert_non_full :: proc(tree: ^BTree($T, $M), node: ^BTreeNode(T, M), value: T) {
    i := node.num_keys - 1

    if node.is_leaf {
        // Insert into leaf
        for i >= 0 && value < node.keys[i] {
            node.keys[i + 1] = node.keys[i]
            i -= 1
        }

        node.keys[i + 1] = value
        node.num_keys += 1
    } else {
        // Find child to insert into
        for i >= 0 && value < node.keys[i] {
            i -= 1
        }
        i += 1

        if node.children[i].num_keys == M - 1 {
            _btree_split_child(tree, node, i)

            if value > node.keys[i] {
                i += 1
            }
        }

        _btree_insert_non_full(tree, node.children[i], value)
    }
}

_btree_split_child :: proc(tree: ^BTree($T, $M), parent: ^BTreeNode(T, M), index: int) {
    full_child := parent.children[index]
    new_child := new(BTreeNode(T, M), tree.allocator)

    new_child.is_leaf = full_child.is_leaf
    new_child.num_keys = tree.min_degree - 1

    // Copy second half of keys to new child
    for j := 0; j < tree.min_degree - 1; j += 1 {
        new_child.keys[j] = full_child.keys[j + tree.min_degree]
    }

    // Copy second half of children if not leaf
    if !full_child.is_leaf {
        for j := 0; j < tree.min_degree; j += 1 {
            new_child.children[j] = full_child.children[j + tree.min_degree]
        }
    }

    full_child.num_keys = tree.min_degree - 1

    // Shift parent's children to make room
    for j := parent.num_keys; j > index; j -= 1 {
        parent.children[j + 1] = parent.children[j]
    }
    parent.children[index + 1] = new_child

    // Move middle key to parent
    for j := parent.num_keys - 1; j >= index; j -= 1 {
        parent.keys[j + 1] = parent.keys[j]
    }
    parent.keys[index] = full_child.keys[tree.min_degree - 1]

    parent.num_keys += 1
}

// btree_len returns the number of elements
btree_len :: proc(tree: ^BTree($T, $M)) -> int {
    return tree.size
}

// btree_is_empty checks if the tree is empty
btree_is_empty :: proc(tree: ^BTree($T, $M)) -> bool {
    return tree.root.num_keys == 0
}
