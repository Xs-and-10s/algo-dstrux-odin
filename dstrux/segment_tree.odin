package dstrux

import "core:mem"

// SegmentTree is a tree for range queries
SegmentTree :: struct($T: typeid) {
    tree: []T,
    data: []T,
    n: int,
    combine: proc(a, b: T) -> T,
    allocator: mem.Allocator,
}

// segment_tree_make creates a new SegmentTree
segment_tree_make :: proc($T: typeid, data: []T, combine: proc(a, b: T) -> T, allocator := context.allocator) -> SegmentTree(T) {
    n := len(data)
    tree := make([]T, 4 * n, allocator)
    data_copy := make([]T, n, allocator)
    copy(data_copy, data)

    st := SegmentTree(T) {
        tree = tree,
        data = data_copy,
        n = n,
        combine = combine,
        allocator = allocator,
    }

    if n > 0 {
        _segment_tree_build(&st, 0, 0, n - 1)
    }

    return st
}

// segment_tree_destroy frees the SegmentTree
segment_tree_destroy :: proc(st: ^SegmentTree($T)) {
    delete(st.tree)
    delete(st.data)
}

// _segment_tree_build builds the segment tree
_segment_tree_build :: proc(st: ^SegmentTree($T), node, start, end: int) {
    if start == end {
        st.tree[node] = st.data[start]
    } else {
        mid := (start + end) / 2
        left_child := 2 * node + 1
        right_child := 2 * node + 2

        _segment_tree_build(st, left_child, start, mid)
        _segment_tree_build(st, right_child, mid + 1, end)

        st.tree[node] = st.combine(st.tree[left_child], st.tree[right_child])
    }
}

// segment_tree_query performs a range query [l, r]
segment_tree_query :: proc(st: ^SegmentTree($T), l, r: int) -> T {
    return _segment_tree_query(st, 0, 0, st.n - 1, l, r)
}

_segment_tree_query :: proc(st: ^SegmentTree($T), node, start, end, l, r: int) -> T {
    if r < start || end < l {
        // Out of range - return default value
        return {}
    }

    if l <= start && end <= r {
        // Completely within range
        return st.tree[node]
    }

    // Partial overlap
    mid := (start + end) / 2
    left_child := 2 * node + 1
    right_child := 2 * node + 2

    left_val := _segment_tree_query(st, left_child, start, mid, l, r)
    right_val := _segment_tree_query(st, right_child, mid + 1, end, l, r)

    return st.combine(left_val, right_val)
}

// segment_tree_update updates a value at the given index
segment_tree_update :: proc(st: ^SegmentTree($T), idx: int, value: T) {
    st.data[idx] = value
    _segment_tree_update(st, 0, 0, st.n - 1, idx, value)
}

_segment_tree_update :: proc(st: ^SegmentTree($T), node, start, end, idx: int, value: T) {
    if start == end {
        st.tree[node] = value
    } else {
        mid := (start + end) / 2
        left_child := 2 * node + 1
        right_child := 2 * node + 2

        if idx <= mid {
            _segment_tree_update(st, left_child, start, mid, idx, value)
        } else {
            _segment_tree_update(st, right_child, mid + 1, end, idx, value)
        }

        st.tree[node] = st.combine(st.tree[left_child], st.tree[right_child])
    }
}
