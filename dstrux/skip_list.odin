package dstrux

import "core:mem"
import "core:math/rand"

// SkipListNode represents a node in a skip list
SkipListNode :: struct($T: typeid) {
    value: T,
    forward: [dynamic]^SkipListNode(T),
}

// SkipList is a probabilistic alternative to balanced trees
SkipList :: struct($T: typeid) {
    header: ^SkipListNode(T),
    max_level: int,
    level: int,
    size: int,
    allocator: mem.Allocator,
}

SKIP_LIST_MAX_LEVEL :: 16
SKIP_LIST_P :: 0.5

// skip_list_make creates a new SkipList
skip_list_make :: proc($T: typeid, allocator := context.allocator) -> SkipList(T) {
    header := new(SkipListNode(T), allocator)
    header.forward = make([dynamic]^SkipListNode(T), SKIP_LIST_MAX_LEVEL, allocator)

    return SkipList(T) {
        header = header,
        max_level = SKIP_LIST_MAX_LEVEL,
        level = 0,
        size = 0,
        allocator = allocator,
    }
}

// skip_list_destroy frees the SkipList
skip_list_destroy :: proc(list: ^SkipList($T)) {
    current := list.header.forward[0]
    for current != nil {
        next := current.forward[0]
        delete(current.forward)
        free(current, list.allocator)
        current = next
    }

    delete(list.header.forward)
    free(list.header, list.allocator)
}

// _skip_list_random_level generates a random level
_skip_list_random_level :: proc(max_level: int) -> int {
    level := 0
    for rand.float32() < SKIP_LIST_P && level < max_level - 1 {
        level += 1
    }
    return level
}

// skip_list_insert adds a value to the skip list
skip_list_insert :: proc(list: ^SkipList($T), value: T) where T: ordered {
    update := make([dynamic]^SkipListNode(T), list.max_level, context.temp_allocator)
    current := list.header

    for i := list.level; i >= 0; i -= 1 {
        for current.forward[i] != nil && current.forward[i].value < value {
            current = current.forward[i]
        }
        update[i] = current
    }

    current = current.forward[0]

    if current == nil || current.value != value {
        new_level := _skip_list_random_level(list.max_level)

        if new_level > list.level {
            for i := list.level + 1; i <= new_level; i += 1 {
                update[i] = list.header
            }
            list.level = new_level
        }

        new_node := new(SkipListNode(T), list.allocator)
        new_node.value = value
        new_node.forward = make([dynamic]^SkipListNode(T), new_level + 1, list.allocator)

        for i := 0; i <= new_level; i += 1 {
            new_node.forward[i] = update[i].forward[i]
            update[i].forward[i] = new_node
        }

        list.size += 1
    }
}

// skip_list_search searches for a value in the skip list
skip_list_search :: proc(list: ^SkipList($T), value: T) -> bool where T: ordered {
    current := list.header

    for i := list.level; i >= 0; i -= 1 {
        for current.forward[i] != nil && current.forward[i].value < value {
            current = current.forward[i]
        }
    }

    current = current.forward[0]

    return current != nil && current.value == value
}

// skip_list_remove removes a value from the skip list
skip_list_remove :: proc(list: ^SkipList($T), value: T) -> bool where T: ordered {
    update := make([dynamic]^SkipListNode(T), list.max_level, context.temp_allocator)
    current := list.header

    for i := list.level; i >= 0; i -= 1 {
        for current.forward[i] != nil && current.forward[i].value < value {
            current = current.forward[i]
        }
        update[i] = current
    }

    current = current.forward[0]

    if current != nil && current.value == value {
        for i := 0; i <= list.level; i += 1 {
            if update[i].forward[i] != current {
                break
            }
            update[i].forward[i] = current.forward[i]
        }

        delete(current.forward)
        free(current, list.allocator)

        for list.level > 0 && list.header.forward[list.level] == nil {
            list.level -= 1
        }

        list.size -= 1
        return true
    }

    return false
}

// skip_list_len returns the number of elements
skip_list_len :: proc(list: ^SkipList($T)) -> int {
    return list.size
}

// skip_list_is_empty checks if the skip list is empty
skip_list_is_empty :: proc(list: ^SkipList($T)) -> bool {
    return list.size == 0
}
