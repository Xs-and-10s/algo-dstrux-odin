package dstrux

import "core:mem"

// RingBuffer is a fixed-size circular buffer
RingBuffer :: struct($T: typeid) {
    data: []T,
    head: int,
    tail: int,
    size: int,
    capacity: int,
    allocator: mem.Allocator,
}

// ring_buffer_make creates a new RingBuffer
ring_buffer_make :: proc($T: typeid, capacity: int, allocator := context.allocator) -> RingBuffer(T) {
    return RingBuffer(T) {
        data = make([]T, capacity, allocator),
        head = 0,
        tail = 0,
        size = 0,
        capacity = capacity,
        allocator = allocator,
    }
}

// ring_buffer_destroy frees the RingBuffer
ring_buffer_destroy :: proc(rb: ^RingBuffer($T)) {
    delete(rb.data)
}

// ring_buffer_push adds an element, overwriting the oldest if full
ring_buffer_push :: proc(rb: ^RingBuffer($T), value: T) {
    rb.data[rb.tail] = value
    rb.tail = (rb.tail + 1) % rb.capacity

    if rb.size < rb.capacity {
        rb.size += 1
    } else {
        // Buffer is full, move head forward
        rb.head = (rb.head + 1) % rb.capacity
    }
}

// ring_buffer_pop removes and returns the oldest element
ring_buffer_pop :: proc(rb: ^RingBuffer($T)) -> (T, bool) {
    if rb.size == 0 {
        return {}, false
    }

    value := rb.data[rb.head]
    rb.head = (rb.head + 1) % rb.capacity
    rb.size -= 1

    return value, true
}

// ring_buffer_peek returns the oldest element without removing it
ring_buffer_peek :: proc(rb: ^RingBuffer($T)) -> (T, bool) {
    if rb.size == 0 {
        return {}, false
    }
    return rb.data[rb.head], true
}

// ring_buffer_get returns the element at the given index (0 = oldest)
ring_buffer_get :: proc(rb: ^RingBuffer($T), index: int) -> (T, bool) {
    if index < 0 || index >= rb.size {
        return {}, false
    }
    actual_index := (rb.head + index) % rb.capacity
    return rb.data[actual_index], true
}

// ring_buffer_len returns the number of elements
ring_buffer_len :: proc(rb: ^RingBuffer($T)) -> int {
    return rb.size
}

// ring_buffer_capacity returns the maximum capacity
ring_buffer_capacity :: proc(rb: ^RingBuffer($T)) -> int {
    return rb.capacity
}

// ring_buffer_is_empty checks if the buffer is empty
ring_buffer_is_empty :: proc(rb: ^RingBuffer($T)) -> bool {
    return rb.size == 0
}

// ring_buffer_is_full checks if the buffer is full
ring_buffer_is_full :: proc(rb: ^RingBuffer($T)) -> bool {
    return rb.size == rb.capacity
}

// ring_buffer_clear removes all elements
ring_buffer_clear :: proc(rb: ^RingBuffer($T)) {
    rb.head = 0
    rb.tail = 0
    rb.size = 0
}
