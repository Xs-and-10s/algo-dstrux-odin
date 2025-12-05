package dstrux

import "core:mem"

// DoublyLinkedListNode represents a node in a doubly linked list
DoublyLinkedListNode :: struct($T: typeid) {
    value: T,
    next: ^DoublyLinkedListNode(T),
    prev: ^DoublyLinkedListNode(T),
}

// DoublyLinkedList is a doubly linked list
DoublyLinkedList :: struct($T: typeid) {
    head: ^DoublyLinkedListNode(T),
    tail: ^DoublyLinkedListNode(T),
    length: int,
    allocator: mem.Allocator,
}

// dll_make creates a new DoublyLinkedList
dll_make :: proc($T: typeid, allocator := context.allocator) -> DoublyLinkedList(T) {
    return DoublyLinkedList(T) {
        head = nil,
        tail = nil,
        length = 0,
        allocator = allocator,
    }
}

// dll_destroy frees the DoublyLinkedList
dll_destroy :: proc(list: ^DoublyLinkedList($T)) {
    current := list.head
    for current != nil {
        next := current.next
        free(current, list.allocator)
        current = next
    }
    list.head = nil
    list.tail = nil
    list.length = 0
}

// dll_push_front adds an element to the front
dll_push_front :: proc(list: ^DoublyLinkedList($T), value: T) {
    node := new(DoublyLinkedListNode(T), list.allocator)
    node.value = value
    node.next = list.head
    node.prev = nil

    if list.head != nil {
        list.head.prev = node
    } else {
        list.tail = node
    }

    list.head = node
    list.length += 1
}

// dll_push_back adds an element to the back
dll_push_back :: proc(list: ^DoublyLinkedList($T), value: T) {
    node := new(DoublyLinkedListNode(T), list.allocator)
    node.value = value
    node.next = nil
    node.prev = list.tail

    if list.tail != nil {
        list.tail.next = node
    } else {
        list.head = node
    }

    list.tail = node
    list.length += 1
}

// dll_pop_front removes and returns the front element
dll_pop_front :: proc(list: ^DoublyLinkedList($T)) -> (T, bool) {
    if list.head == nil {
        return {}, false
    }

    node := list.head
    value := node.value
    list.head = node.next

    if list.head != nil {
        list.head.prev = nil
    } else {
        list.tail = nil
    }

    free(node, list.allocator)
    list.length -= 1

    return value, true
}

// dll_pop_back removes and returns the back element
dll_pop_back :: proc(list: ^DoublyLinkedList($T)) -> (T, bool) {
    if list.tail == nil {
        return {}, false
    }

    node := list.tail
    value := node.value
    list.tail = node.prev

    if list.tail != nil {
        list.tail.next = nil
    } else {
        list.head = nil
    }

    free(node, list.allocator)
    list.length -= 1

    return value, true
}

// dll_peek_front returns the front element without removing it
dll_peek_front :: proc(list: ^DoublyLinkedList($T)) -> (T, bool) {
    if list.head == nil {
        return {}, false
    }
    return list.head.value, true
}

// dll_peek_back returns the back element without removing it
dll_peek_back :: proc(list: ^DoublyLinkedList($T)) -> (T, bool) {
    if list.tail == nil {
        return {}, false
    }
    return list.tail.value, true
}

// dll_find searches for a value in the list
dll_find :: proc(list: ^DoublyLinkedList($T), value: T) -> ^DoublyLinkedListNode(T) where T: comparable {
    current := list.head
    for current != nil {
        if current.value == value {
            return current
        }
        current = current.next
    }
    return nil
}

// dll_remove removes the first occurrence of a value
dll_remove :: proc(list: ^DoublyLinkedList($T), value: T) -> bool where T: comparable {
    current := list.head
    for current != nil {
        if current.value == value {
            if current.prev != nil {
                current.prev.next = current.next
            } else {
                list.head = current.next
            }

            if current.next != nil {
                current.next.prev = current.prev
            } else {
                list.tail = current.prev
            }

            free(current, list.allocator)
            list.length -= 1
            return true
        }
        current = current.next
    }
    return false
}

// dll_len returns the number of elements
dll_len :: proc(list: ^DoublyLinkedList($T)) -> int {
    return list.length
}

// dll_is_empty checks if the list is empty
dll_is_empty :: proc(list: ^DoublyLinkedList($T)) -> bool {
    return list.head == nil
}
