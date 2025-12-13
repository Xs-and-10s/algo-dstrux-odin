package dstrux

import "core:mem"

// MinMaxHeap is a double-ended priority queue
// Elements at even levels are min levels, odd levels are max levels
MinMaxHeap :: struct($T: typeid) {
	data:      [dynamic]T,
	allocator: mem.Allocator,
}

// minmax_heap_make creates a new MinMaxHeap
minmax_heap_make :: proc(
	$T: typeid,
	capacity: int = 16,
	allocator := context.allocator,
) -> MinMaxHeap(T) {
	return MinMaxHeap(T){data = make([dynamic]T, 0, capacity, allocator), allocator = allocator}
}

// minmax_heap_destroy frees the MinMaxHeap
minmax_heap_destroy :: proc(heap: ^MinMaxHeap($T)) {
	delete(heap.data)
}

// _minmax_heap_level returns the level of an index (0-indexed)
_minmax_heap_level :: proc(index: int) -> int {
	level := 0
	idx := index + 1 // Convert to 1-indexed
	for idx > 1 {
		idx /= 2
		level += 1
	}
	return level
}

// _minmax_heap_is_min_level checks if an index is at a min level
_minmax_heap_is_min_level :: proc(index: int) -> bool {
	return _minmax_heap_level(index) % 2 == 0
}

// minmax_heap_push adds an element to the heap
minmax_heap_push :: proc(heap: ^MinMaxHeap($T), value: T) {
	append(&heap.data, value)
	_minmax_heap_push_up(heap, len(heap.data) - 1)
}

// minmax_heap_pop_min removes and returns the minimum element
minmax_heap_pop_min :: proc(heap: ^MinMaxHeap($T)) -> (T, bool) {
	if len(heap.data) == 0 {
		return {}, false
	}

	result := heap.data[0]
	last := pop(&heap.data)

	if len(heap.data) > 0 {
		heap.data[0] = last
		_minmax_heap_push_down_min(heap, 0)
	}

	return result, true
}

// minmax_heap_pop_max removes and returns the maximum element
minmax_heap_pop_max :: proc(heap: ^MinMaxHeap($T)) -> (T, bool) {
	n := len(heap.data)
	if n == 0 {
		return {}, false
	}

	if n == 1 {
		return pop(&heap.data), true
	}

	// Max is at index 1 or 2
	max_idx := 1
	if n > 2 && heap.data[2] > heap.data[1] {
		max_idx = 2
	}

	result := heap.data[max_idx]
	last := pop(&heap.data)

	if max_idx < len(heap.data) {
		heap.data[max_idx] = last
		_minmax_heap_push_down_max(heap, max_idx)
	}

	return result, true
}

// minmax_heap_peek_min returns the minimum element without removing it
minmax_heap_peek_min :: proc(heap: ^MinMaxHeap($T)) -> (T, bool) {
	if len(heap.data) == 0 {
		return {}, false
	}
	return heap.data[0], true
}

// minmax_heap_peek_max returns the maximum element without removing it
minmax_heap_peek_max :: proc(heap: ^MinMaxHeap($T)) -> (T, bool) {
	n := len(heap.data)
	if n == 0 {
		return {}, false
	}
	if n == 1 {
		return heap.data[0], true
	}

	max_idx := 1
	if n > 2 && heap.data[2] > heap.data[1] {
		max_idx = 2
	}

	return heap.data[max_idx], true
}

// minmax_heap_len returns the number of elements
minmax_heap_len :: proc(heap: ^MinMaxHeap($T)) -> int {
	return len(heap.data)
}

// minmax_heap_is_empty checks if the heap is empty
minmax_heap_is_empty :: proc(heap: ^MinMaxHeap($T)) -> bool {
	return len(heap.data) == 0
}

// _minmax_heap_push_up moves an element up to maintain heap property
_minmax_heap_push_up :: proc(heap: ^MinMaxHeap($T), index: int) {
	if index == 0 do return

	parent := (index - 1) / 2

	if _minmax_heap_is_min_level(index) {
		if heap.data[index] > heap.data[parent] {
			heap.data[index], heap.data[parent] = heap.data[parent], heap.data[index]
			_minmax_heap_push_up_max(heap, parent)
		} else {
			_minmax_heap_push_up_min(heap, index)
		}
	} else {
		if heap.data[index] < heap.data[parent] {
			heap.data[index], heap.data[parent] = heap.data[parent], heap.data[index]
			_minmax_heap_push_up_min(heap, parent)
		} else {
			_minmax_heap_push_up_max(heap, index)
		}
	}
}

_minmax_heap_push_up_min :: proc(heap: ^MinMaxHeap($T), index: int) {
	idx := index
	for idx > 2 {
		grandparent := (idx - 3) / 4
		if heap.data[idx] < heap.data[grandparent] {
			heap.data[idx], heap.data[grandparent] = heap.data[grandparent], heap.data[idx]
			idx = grandparent
		} else {
			break
		}
	}
}

_minmax_heap_push_up_max :: proc(heap: ^MinMaxHeap($T), index: int) {
	idx := index
	for idx > 2 {
		grandparent := (idx - 3) / 4
		if heap.data[idx] > heap.data[grandparent] {
			heap.data[idx], heap.data[grandparent] = heap.data[grandparent], heap.data[idx]
			idx = grandparent
		} else {
			break
		}
	}
}

_minmax_heap_push_down_min :: proc(heap: ^MinMaxHeap($T), index: int) {
	// Simplified push down for min level
	idx := index
	n := len(heap.data)

	for {
		smallest := idx
		left := 2 * idx + 1
		right := 2 * idx + 2

		if left < n && heap.data[left] < heap.data[smallest] {
			smallest = left
		}
		if right < n && heap.data[right] < heap.data[smallest] {
			smallest = right
		}

		if smallest == idx do break

		heap.data[idx], heap.data[smallest] = heap.data[smallest], heap.data[idx]
		idx = smallest
	}
}

_minmax_heap_push_down_max :: proc(heap: ^MinMaxHeap($T), index: int) {
	// Simplified push down for max level
	idx := index
	n := len(heap.data)

	for {
		largest := idx
		left := 2 * idx + 1
		right := 2 * idx + 2

		if left < n && heap.data[left] > heap.data[largest] {
			largest = left
		}
		if right < n && heap.data[right] > heap.data[largest] {
			largest = right
		}

		if largest == idx do break

		heap.data[idx], heap.data[largest] = heap.data[largest], heap.data[idx]
		idx = largest
	}
}
