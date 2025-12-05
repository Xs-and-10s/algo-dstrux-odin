package dstrux

import "core:mem"

// DisjointSet (Union-Find) is a data structure for tracking disjoint sets
DisjointSet :: struct {
    parent: []int,
    rank: []int,
    num_sets: int,
    allocator: mem.Allocator,
}

// disjoint_set_make creates a new DisjointSet
disjoint_set_make :: proc(size: int, allocator := context.allocator) -> DisjointSet {
    parent := make([]int, size, allocator)
    rank := make([]int, size, allocator)

    for i := 0; i < size; i += 1 {
        parent[i] = i
        rank[i] = 0
    }

    return DisjointSet {
        parent = parent,
        rank = rank,
        num_sets = size,
        allocator = allocator,
    }
}

// disjoint_set_destroy frees the DisjointSet
disjoint_set_destroy :: proc(ds: ^DisjointSet) {
    delete(ds.parent)
    delete(ds.rank)
}

// disjoint_set_find finds the representative of the set containing x
disjoint_set_find :: proc(ds: ^DisjointSet, x: int) -> int {
    if ds.parent[x] != x {
        // Path compression
        ds.parent[x] = disjoint_set_find(ds, ds.parent[x])
    }
    return ds.parent[x]
}

// disjoint_set_union merges the sets containing x and y
disjoint_set_union :: proc(ds: ^DisjointSet, x, y: int) -> bool {
    root_x := disjoint_set_find(ds, x)
    root_y := disjoint_set_find(ds, y)

    if root_x == root_y {
        return false // Already in same set
    }

    // Union by rank
    if ds.rank[root_x] < ds.rank[root_y] {
        ds.parent[root_x] = root_y
    } else if ds.rank[root_x] > ds.rank[root_y] {
        ds.parent[root_y] = root_x
    } else {
        ds.parent[root_y] = root_x
        ds.rank[root_x] += 1
    }

    ds.num_sets -= 1
    return true
}

// disjoint_set_connected checks if x and y are in the same set
disjoint_set_connected :: proc(ds: ^DisjointSet, x, y: int) -> bool {
    return disjoint_set_find(ds, x) == disjoint_set_find(ds, y)
}

// disjoint_set_count returns the number of disjoint sets
disjoint_set_count :: proc(ds: ^DisjointSet) -> int {
    return ds.num_sets
}
