package dstrux

import "core:mem"

// SinglyLinkedListNode represents a node in a singly linked list
SinglyLinkedListNode :: struct($T: typeid) {
    value: T,
    next: ^SinglyLinkedListNode(T),
}

// SinglyLinkedList is a singly linked list
SinglyLinkedList :: struct($T: typeid) {
    head: ^SinglyLinkedListNode(T),
    tail: ^SinglyLinkedListNode(T),
    length: int,
    allocator: mem.Allocator,
}

// sll_make creates a new SinglyLinkedList
sll_make :: proc($T: typeid, allocator := context.allocator) -> SinglyLinkedList(T) {
    return SinglyLinkedList(T) {
        head = nil,
        tail = nil,
        length = 0,
        allocator = allocator,
    }
}

// sll_destroy frees the SinglyLinkedList
sll_destroy :: proc(list: ^SinglyLinkedList($T)) {
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

// sll_push_front adds an element to the front
sll_push_front :: proc(list: ^SinglyLinkedList($T), value: T) {
    node := new(SinglyLinkedListNode(T), list.allocator)
    node.value = value
    node.next = list.head
    list.head = node

    if list.tail == nil {
        list.tail = node
    }

    list.length += 1
}

// sll_push_back adds an element to the back
sll_push_back :: proc(list: ^SinglyLinkedList($T), value: T) {
    node := new(SinglyLinkedListNode(T), list.allocator)
    node.value = value
    node.next = nil

    if list.tail != nil {
        list.tail.next = node
    } else {
        list.head = node
    }

    list.tail = node
    list.length += 1
}

// sll_pop_front removes and returns the front element
sll_pop_front :: proc(list: ^SinglyLinkedList($T)) -> (T, bool) {
    if list.head == nil {
        return {}, false
    }

    node := list.head
    value := node.value
    list.head = node.next

    if list.head == nil {
        list.tail = nil
    }

    free(node, list.allocator)
    list.length -= 1

    return value, true
}

// sll_peek_front returns the front element without removing it
sll_peek_front :: proc(list: ^SinglyLinkedList($T)) -> (T, bool) {
    if list.head == nil {
        return {}, false
    }
    return list.head.value, true
}

// sll_find searches for a value in the list
sll_find :: proc(list: ^SinglyLinkedList($T), value: T) -> ^SinglyLinkedListNode(T) where T: comparable {
    current := list.head
    for current != nil {
        if current.value == value {
            return current
        }
        current = current.next
    }
    return nil
}

// sll_remove removes the first occurrence of a value
sll_remove :: proc(list: ^SinglyLinkedList($T), value: T) -> bool where T: comparable {
    if list.head == nil {
        return false
    }

    if list.head.value == value {
        _, ok := sll_pop_front(list)
        return ok
    }

    current := list.head
    for current.next != nil {
        if current.next.value == value {
            node := current.next
            current.next = node.next

            if node == list.tail {
                list.tail = current
            }

            free(node, list.allocator)
            list.length -= 1
            return true
        }
        current = current.next
    }

    return false
}

// sll_len returns the number of elements
sll_len :: proc(list: ^SinglyLinkedList($T)) -> int {
    return list.length
}

// sll_is_empty checks if the list is empty
sll_is_empty :: proc(list: ^SinglyLinkedList($T)) -> bool {
    return list.head == nil
}
