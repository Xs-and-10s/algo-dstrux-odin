package dstrux

import "core:mem"

// Queue is a FIFO data structure
Queue :: struct($T: typeid) {
    data: [dynamic]T,
    front: int,
    allocator: mem.Allocator,
}

// queue_make creates a new Queue
queue_make :: proc($T: typeid, capacity: int = 16, allocator := context.allocator) -> Queue(T) {
    return Queue(T) {
        data = make([dynamic]T, 0, capacity, allocator),
        front = 0,
        allocator = allocator,
    }
}

// queue_destroy frees the Queue
queue_destroy :: proc(queue: ^Queue($T)) {
    delete(queue.data)
}

// queue_enqueue adds an element to the back
queue_enqueue :: proc(queue: ^Queue($T), value: T) {
    append(&queue.data, value)
}

// queue_dequeue removes and returns the front element
queue_dequeue :: proc(queue: ^Queue($T)) -> (T, bool) {
    if queue.front >= len(queue.data) {
        return {}, false
    }
    value := queue.data[queue.front]
    queue.front += 1

    // Periodically compact the queue to avoid wasting memory
    if queue.front > len(queue.data) / 2 && queue.front > 16 {
        copy(queue.data[:], queue.data[queue.front:])
        resize(&queue.data, len(queue.data) - queue.front)
        queue.front = 0
    }

    return value, true
}

// queue_peek returns the front element without removing it
queue_peek :: proc(queue: ^Queue($T)) -> (T, bool) {
    if queue.front >= len(queue.data) {
        return {}, false
    }
    return queue.data[queue.front], true
}

// queue_len returns the number of elements
queue_len :: proc(queue: ^Queue($T)) -> int {
    return len(queue.data) - queue.front
}

// queue_is_empty checks if the queue is empty
queue_is_empty :: proc(queue: ^Queue($T)) -> bool {
    return queue.front >= len(queue.data)
}

// queue_clear removes all elements
queue_clear :: proc(queue: ^Queue($T)) {
    clear(&queue.data)
    queue.front = 0
}
