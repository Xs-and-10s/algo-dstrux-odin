package dstrux

import "core:fmt"
import "core:mem"

// ArrayList is a dynamic array that grows as needed
ArrayList :: struct($T: typeid) {
    data: [dynamic]T,
    allocator: mem.Allocator,
}

// arraylist_make creates a new ArrayList with optional capacity
arraylist_make :: proc($T: typeid, capacity: int = 16, allocator := context.allocator) -> ArrayList(T) {
    return ArrayList(T) {
        data = make([dynamic]T, 0, capacity, allocator),
        allocator = allocator,
    }
}

// arraylist_destroy frees the ArrayList
arraylist_destroy :: proc(list: ^ArrayList($T)) {
    delete(list.data)
}

// arraylist_append adds an element to the end
arraylist_append :: proc(list: ^ArrayList($T), value: T) {
    append(&list.data, value)
}

// arraylist_insert inserts an element at the given index
arraylist_insert :: proc(list: ^ArrayList($T), index: int, value: T) -> bool {
    if index < 0 || index > len(list.data) do return false
    inject_at(&list.data, index, value)
    return true
}

// arraylist_remove removes and returns the element at the given index
arraylist_remove :: proc(list: ^ArrayList($T), index: int) -> (T, bool) {
    if index < 0 || index >= len(list.data) {
        return {}, false
    }
    value := list.data[index]
    ordered_remove(&list.data, index)
    return value, true
}

// arraylist_get returns the element at the given index
arraylist_get :: proc(list: ^ArrayList($T), index: int) -> (T, bool) {
    if index < 0 || index >= len(list.data) {
        return {}, false
    }
    return list.data[index], true
}

// arraylist_set sets the element at the given index
arraylist_set :: proc(list: ^ArrayList($T), index: int, value: T) -> bool {
    if index < 0 || index >= len(list.data) do return false
    list.data[index] = value
    return true
}

// arraylist_len returns the number of elements
arraylist_len :: proc(list: ^ArrayList($T)) -> int {
    return len(list.data)
}

// arraylist_capacity returns the current capacity
arraylist_capacity :: proc(list: ^ArrayList($T)) -> int {
    return cap(list.data)
}

// arraylist_clear removes all elements
arraylist_clear :: proc(list: ^ArrayList($T)) {
    clear(&list.data)
}

// arraylist_is_empty checks if the list is empty
arraylist_is_empty :: proc(list: ^ArrayList($T)) -> bool {
    return len(list.data) == 0
}
