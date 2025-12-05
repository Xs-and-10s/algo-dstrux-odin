package dstrux

import "core:mem"
import "core:strings"

// RopeNode represents a node in a rope data structure
RopeNode :: struct {
    weight: int, // Length of string in left subtree
    value: string, // Only in leaf nodes
    left: ^RopeNode,
    right: ^RopeNode,
}

// Rope is a tree structure for efficient string operations
Rope :: struct {
    root: ^RopeNode,
    allocator: mem.Allocator,
}

ROPE_SPLIT_LENGTH :: 16

// rope_make creates a new Rope from a string
rope_make :: proc(s: string, allocator := context.allocator) -> Rope {
    return Rope {
        root = _rope_build_from_string(s, allocator),
        allocator = allocator,
    }
}

// rope_destroy frees the Rope
rope_destroy :: proc(rope: ^Rope) {
    _rope_destroy_node(rope, rope.root)
    rope.root = nil
}

_rope_destroy_node :: proc(rope: ^Rope, node: ^RopeNode) {
    if node == nil do return
    _rope_destroy_node(rope, node.left)
    _rope_destroy_node(rope, node.right)
    if node.value != "" {
        delete(node.value, rope.allocator)
    }
    free(node, rope.allocator)
}

// _rope_build_from_string builds a rope from a string
_rope_build_from_string :: proc(s: string, allocator: mem.Allocator) -> ^RopeNode {
    if len(s) <= ROPE_SPLIT_LENGTH {
        node := new(RopeNode, allocator)
        node.weight = len(s)
        node.value = strings.clone(s, allocator)
        node.left = nil
        node.right = nil
        return node
    }

    mid := len(s) / 2
    node := new(RopeNode, allocator)
    node.left = _rope_build_from_string(s[:mid], allocator)
    node.right = _rope_build_from_string(s[mid:], allocator)
    node.weight = _rope_weight(node.left)
    node.value = ""
    return node
}

// _rope_weight returns the weight of a node (length of left subtree)
_rope_weight :: proc(node: ^RopeNode) -> int {
    if node == nil do return 0
    if node.left == nil && node.right == nil {
        return len(node.value)
    }
    return node.weight
}

// rope_concat concatenates two ropes
rope_concat :: proc(rope1, rope2: ^Rope, allocator := context.allocator) -> Rope {
    node := new(RopeNode, allocator)
    node.left = rope1.root
    node.right = rope2.root
    node.weight = _rope_total_length(rope1.root)
    node.value = ""

    return Rope {
        root = node,
        allocator = allocator,
    }
}

// rope_length returns the total length of the rope
rope_length :: proc(rope: ^Rope) -> int {
    return _rope_total_length(rope.root)
}

_rope_total_length :: proc(node: ^RopeNode) -> int {
    if node == nil do return 0
    if node.left == nil && node.right == nil {
        return len(node.value)
    }
    return _rope_total_length(node.left) + _rope_total_length(node.right)
}

// rope_index gets the character at the given index
rope_index :: proc(rope: ^Rope, index: int) -> (u8, bool) {
    return _rope_index_node(rope.root, index)
}

_rope_index_node :: proc(node: ^RopeNode, index: int) -> (u8, bool) {
    if node == nil do return 0, false

    if node.left == nil && node.right == nil {
        if index < 0 || index >= len(node.value) {
            return 0, false
        }
        return node.value[index], true
    }

    if index < node.weight {
        return _rope_index_node(node.left, index)
    } else {
        return _rope_index_node(node.right, index - node.weight)
    }
}

// rope_to_string converts the rope to a string
rope_to_string :: proc(rope: ^Rope, allocator := context.allocator) -> string {
    builder := strings.builder_make(allocator)
    _rope_to_string_node(rope.root, &builder)
    return strings.to_string(builder)
}

_rope_to_string_node :: proc(node: ^RopeNode, builder: ^strings.Builder) {
    if node == nil do return

    if node.left == nil && node.right == nil {
        strings.write_string(builder, node.value)
        return
    }

    _rope_to_string_node(node.left, builder)
    _rope_to_string_node(node.right, builder)
}

// rope_substring extracts a substring [start, end)
rope_substring :: proc(rope: ^Rope, start, end: int, allocator := context.allocator) -> string {
    builder := strings.builder_make(allocator)
    _rope_substring_node(rope.root, start, end, 0, &builder)
    return strings.to_string(builder)
}

_rope_substring_node :: proc(node: ^RopeNode, start, end, offset: int, builder: ^strings.Builder) {
    if node == nil do return

    if node.left == nil && node.right == nil {
        node_end := offset + len(node.value)
        if start >= node_end || end <= offset {
            return
        }

        local_start := max(0, start - offset)
        local_end := min(len(node.value), end - offset)
        strings.write_string(builder, node.value[local_start:local_end])
        return
    }

    _rope_substring_node(node.left, start, end, offset, builder)
    _rope_substring_node(node.right, start, end, offset + node.weight, builder)
}
