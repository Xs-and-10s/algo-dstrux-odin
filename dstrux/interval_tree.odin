package dstrux

import "core:mem"

// Interval represents a range [low, high]
Interval :: struct($T: typeid) {
	low:  T,
	high: T,
}

// IntervalTreeNode represents a node in an interval tree
IntervalTreeNode :: struct($T: typeid) {
	interval: Interval(T),
	max:      T,
	left:     ^IntervalTreeNode(T),
	right:    ^IntervalTreeNode(T),
}

// IntervalTree is a tree for storing intervals
IntervalTree :: struct($T: typeid) {
	root:      ^IntervalTreeNode(T),
	size:      int,
	allocator: mem.Allocator,
}

// interval_tree_make creates a new IntervalTree
interval_tree_make :: proc($T: typeid, allocator := context.allocator) -> IntervalTree(T) {
	return IntervalTree(T){root = nil, size = 0, allocator = allocator}
}

// interval_tree_destroy frees the IntervalTree
interval_tree_destroy :: proc(tree: ^IntervalTree($T)) {
	_interval_tree_destroy_node(tree, tree.root)
	tree.root = nil
	tree.size = 0
}

_interval_tree_destroy_node :: proc(tree: ^IntervalTree($T), node: ^IntervalTreeNode(T)) {
	if node == nil do return
	_interval_tree_destroy_node(tree, node.left)
	_interval_tree_destroy_node(tree, node.right)
	free(node, tree.allocator)
}

// interval_tree_insert adds an interval to the tree
interval_tree_insert :: proc(tree: ^IntervalTree($T), interval: Interval(T)) {
	tree.root = _interval_tree_insert_node(tree, tree.root, interval)
}

_interval_tree_insert_node :: proc(
	tree: ^IntervalTree($T),
	node: ^IntervalTreeNode(T),
	interval: Interval(T),
) -> ^IntervalTreeNode(T) {
	if node == nil {
		new_node := new(IntervalTreeNode(T), tree.allocator)
		new_node.interval = interval
		new_node.max = interval.high
		new_node.left = nil
		new_node.right = nil
		tree.size += 1
		return new_node
	}

	if interval.low < node.interval.low {
		node.left = _interval_tree_insert_node(tree, node.left, interval)
	} else {
		node.right = _interval_tree_insert_node(tree, node.right, interval)
	}

	if node.max < interval.high {
		node.max = interval.high
	}

	return node
}

// interval_tree_overlaps checks if two intervals overlap
_intervals_overlap :: proc(a: Interval($T), b: Interval(T)) -> bool {
	return a.low <= b.high && b.low <= a.high
}

// interval_tree_search finds an interval that overlaps with the given interval
interval_tree_search :: proc(
	tree: ^IntervalTree($T),
	interval: Interval(T),
) -> (
	Interval(T),
	bool,
) {
	return _interval_tree_search_node(tree.root, interval)
}

_interval_tree_search_node :: proc(
	node: ^IntervalTreeNode($T),
	interval: Interval(T),
) -> (
	Interval(T),
	bool,
) {
	if node == nil {
		return {}, false
	}

	if _intervals_overlap(node.interval, interval) {
		return node.interval, true
	}

	if node.left != nil && node.left.max >= interval.low {
		return _interval_tree_search_node(node.left, interval)
	}

	return _interval_tree_search_node(node.right, interval)
}

// interval_tree_len returns the number of intervals
interval_tree_len :: proc(tree: ^IntervalTree($T)) -> int {
	return tree.size
}

// interval_tree_is_empty checks if the tree is empty
interval_tree_is_empty :: proc(tree: ^IntervalTree($T)) -> bool {
	return tree.root == nil
}
