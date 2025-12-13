package dstrux

import "core:mem"

// HeapType represents the type of heap (min or max)
HeapType :: enum {
    Min,
    Max,
}

// BinaryHeap is a binary heap (min or max)
BinaryHeap :: struct($T: typeid) {
    data: [dynamic]T,
    heap_type: HeapType,
    allocator: mem.Allocator,
}

// binary_heap_make creates a new BinaryHeap
binary_heap_make :: proc($T: typeid, heap_type: HeapType = .Min, capacity: int = 16, allocator := context.allocator) -> BinaryHeap(T) {
    return BinaryHeap(T) {
        data = make([dynamic]T, 0, capacity, allocator),
        heap_type = heap_type,
        allocator = allocator,
    }
}

// binary_heap_destroy frees the BinaryHeap
binary_heap_destroy :: proc(heap: ^BinaryHeap($T)) {
    delete(heap.data)
}

// binary_heap_compare compares two values based on heap type
_binary_heap_compare :: proc(heap: ^BinaryHeap($T), a, b: T) -> bool {
    if heap.heap_type == .Min {
        return a < b
    } else {
        return a > b
    }
}

// binary_heap_push adds an element to the heap
binary_heap_push :: proc(heap: ^BinaryHeap($T), value: T) {
    append(&heap.data, value)
    _binary_heap_sift_up(heap, len(heap.data) - 1)
}

// binary_heap_pop removes and returns the top element
binary_heap_pop :: proc(heap: ^BinaryHeap($T)) -> (T, bool) {
    if len(heap.data) == 0 {
        return {}, false
    }

    result := heap.data[0]
    last := pop(&heap.data)

    if len(heap.data) > 0 {
        heap.data[0] = last
        _binary_heap_sift_down(heap, 0)
    }

    return result, true
}

// binary_heap_peek returns the top element without removing it
binary_heap_peek :: proc(heap: ^BinaryHeap($T)) -> (T, bool) {
    if len(heap.data) == 0 {
        return {}, false
    }
    return heap.data[0], true
}

// binary_heap_len returns the number of elements
binary_heap_len :: proc(heap: ^BinaryHeap($T)) -> int {
    return len(heap.data)
}

// binary_heap_is_empty checks if the heap is empty
binary_heap_is_empty :: proc(heap: ^BinaryHeap($T)) -> bool {
    return len(heap.data) == 0
}

// _binary_heap_sift_up moves an element up to maintain heap property
_binary_heap_sift_up :: proc(heap: ^BinaryHeap($T), index: int) {
    idx := index
    for idx > 0 {
        parent := (idx - 1) / 2
        if _binary_heap_compare(heap, heap.data[idx], heap.data[parent]) {
            heap.data[idx], heap.data[parent] = heap.data[parent], heap.data[idx]
            idx = parent
        } else {
            break
        }
    }
}

// _binary_heap_sift_down moves an element down to maintain heap property
_binary_heap_sift_down :: proc(heap: ^BinaryHeap($T), index: int) {
    idx := index
    n := len(heap.data)

    for {
        left := 2 * idx + 1
        right := 2 * idx + 2
        target := idx

        if left < n && _binary_heap_compare(heap, heap.data[left], heap.data[target]) {
            target = left
        }

        if right < n && _binary_heap_compare(heap, heap.data[right], heap.data[target]) {
            target = right
        }

        if target == idx {
            break
        }

        heap.data[idx], heap.data[target] = heap.data[target], heap.data[idx]
        idx = target
    }
}
