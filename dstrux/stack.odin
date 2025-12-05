package dstrux

import "core:mem"

// Stack is a LIFO data structure
Stack :: struct($T: typeid) {
    data: [dynamic]T,
    allocator: mem.Allocator,
}

// stack_make creates a new Stack
stack_make :: proc($T: typeid, capacity: int = 16, allocator := context.allocator) -> Stack(T) {
    return Stack(T) {
        data = make([dynamic]T, 0, capacity, allocator),
        allocator = allocator,
    }
}

// stack_destroy frees the Stack
stack_destroy :: proc(stack: ^Stack($T)) {
    delete(stack.data)
}

// stack_push adds an element to the top
stack_push :: proc(stack: ^Stack($T), value: T) {
    append(&stack.data, value)
}

// stack_pop removes and returns the top element
stack_pop :: proc(stack: ^Stack($T)) -> (T, bool) {
    if len(stack.data) == 0 {
        return {}, false
    }
    value := pop(&stack.data)
    return value, true
}

// stack_peek returns the top element without removing it
stack_peek :: proc(stack: ^Stack($T)) -> (T, bool) {
    if len(stack.data) == 0 {
        return {}, false
    }
    return stack.data[len(stack.data) - 1], true
}

// stack_len returns the number of elements
stack_len :: proc(stack: ^Stack($T)) -> int {
    return len(stack.data)
}

// stack_is_empty checks if the stack is empty
stack_is_empty :: proc(stack: ^Stack($T)) -> bool {
    return len(stack.data) == 0
}

// stack_clear removes all elements
stack_clear :: proc(stack: ^Stack($T)) {
    clear(&stack.data)
}
