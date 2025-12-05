package dstrux

import "core:mem"

// Deque is a double-ended queue
Deque :: struct($T: typeid) {
    data: [dynamic]T,
    front: int,
    back: int,
    allocator: mem.Allocator,
}

// deque_make creates a new Deque
deque_make :: proc($T: typeid, capacity: int = 16, allocator := context.allocator) -> Deque(T) {
    return Deque(T) {
        data = make([dynamic]T, capacity, allocator),
        front = capacity / 2,
        back = capacity / 2,
        allocator = allocator,
    }
}

// deque_destroy frees the Deque
deque_destroy :: proc(deque: ^Deque($T)) {
    delete(deque.data)
}

// deque_push_front adds an element to the front
deque_push_front :: proc(deque: ^Deque($T), value: T) {
    if deque.front == 0 {
        _deque_grow_front(deque)
    }
    deque.front -= 1
    deque.data[deque.front] = value
}

// deque_push_back adds an element to the back
deque_push_back :: proc(deque: ^Deque($T), value: T) {
    if deque.back >= len(deque.data) {
        _deque_grow_back(deque)
    }
    deque.data[deque.back] = value
    deque.back += 1
}

// deque_pop_front removes and returns the front element
deque_pop_front :: proc(deque: ^Deque($T)) -> (T, bool) {
    if deque.front >= deque.back {
        return {}, false
    }
    value := deque.data[deque.front]
    deque.front += 1
    return value, true
}

// deque_pop_back removes and returns the back element
deque_pop_back :: proc(deque: ^Deque($T)) -> (T, bool) {
    if deque.front >= deque.back {
        return {}, false
    }
    deque.back -= 1
    value := deque.data[deque.back]
    return value, true
}

// deque_peek_front returns the front element without removing it
deque_peek_front :: proc(deque: ^Deque($T)) -> (T, bool) {
    if deque.front >= deque.back {
        return {}, false
    }
    return deque.data[deque.front], true
}

// deque_peek_back returns the back element without removing it
deque_peek_back :: proc(deque: ^Deque($T)) -> (T, bool) {
    if deque.front >= deque.back {
        return {}, false
    }
    return deque.data[deque.back - 1], true
}

// deque_len returns the number of elements
deque_len :: proc(deque: ^Deque($T)) -> int {
    return deque.back - deque.front
}

// deque_is_empty checks if the deque is empty
deque_is_empty :: proc(deque: ^Deque($T)) -> bool {
    return deque.front >= deque.back
}

// deque_clear removes all elements
deque_clear :: proc(deque: ^Deque($T)) {
    deque.front = len(deque.data) / 2
    deque.back = deque.front
}

// Private helper to grow the front
_deque_grow_front :: proc(deque: ^Deque($T)) {
    old_len := len(deque.data)
    new_len := old_len * 2
    new_data := make([dynamic]T, new_len, deque.allocator)

    offset := new_len - old_len
    copy(new_data[offset:], deque.data[:])

    delete(deque.data)
    deque.data = new_data
    deque.front += offset
    deque.back += offset
}

// Private helper to grow the back
_deque_grow_back :: proc(deque: ^Deque($T)) {
    old_len := len(deque.data)
    new_len := old_len * 2
    resize(&deque.data, new_len)
}
