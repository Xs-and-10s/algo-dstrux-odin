package dstrux

import "core:mem"
import "core:hash"

// HashSetEntry represents an entry in a hashset
HashSetEntry :: struct($T: typeid) {
    value: T,
    occupied: bool,
    deleted: bool,
}

// HashSet is a set implemented using open addressing
HashSet :: struct($T: typeid) {
    entries: []HashSetEntry(T),
    size: int,
    capacity: int,
    allocator: mem.Allocator,
}

// hashset_make creates a new HashSet
hashset_make :: proc($T: typeid, capacity: int = 16, allocator := context.allocator) -> HashSet(T) {
    return HashSet(T) {
        entries = make([]HashSetEntry(T), capacity, allocator),
        size = 0,
        capacity = capacity,
        allocator = allocator,
    }
}

// hashset_destroy frees the HashSet
hashset_destroy :: proc(hs: ^HashSet($T)) {
    delete(hs.entries)
}

// hashset_hash computes the hash for a value
hashset_hash :: proc(hs: ^HashSet($T), value: T) -> int {
    h := hash.crc32(mem.any_to_bytes(value))
    return int(h) % hs.capacity
}

// hashset_insert adds a value to the set
hashset_insert :: proc(hs: ^HashSet($T), value: T) -> bool where T: comparable {
    // Rehash if load factor exceeds 0.7
    load_factor := f32(hs.size) / f32(hs.capacity)
    if load_factor > 0.7 {
        hashset_rehash(hs)
    }

    index := hashset_hash(hs, value)
    original_index := index

    for {
        entry := &hs.entries[index]

        if !entry.occupied || entry.deleted {
            // Found an empty or deleted slot
            if entry.occupied && entry.deleted && entry.value == value {
                // Reusing a deleted slot with the same value
                entry.deleted = false
                hs.size += 1
                return true
            }
            if !entry.occupied || entry.value != value {
                entry.value = value
                entry.occupied = true
                entry.deleted = false
                hs.size += 1
                return true
            }
        }

        if entry.value == value && !entry.deleted {
            // Value already exists
            return false
        }

        // Linear probing
        index = (index + 1) % hs.capacity

        if index == original_index {
            panic("HashSet is full (this should not happen)")
        }
    }
}

// hashset_contains checks if a value exists in the set
hashset_contains :: proc(hs: ^HashSet($T), value: T) -> bool where T: comparable {
    index := hashset_hash(hs, value)
    original_index := index

    for {
        entry := &hs.entries[index]

        if !entry.occupied {
            return false
        }

        if !entry.deleted && entry.value == value {
            return true
        }

        index = (index + 1) % hs.capacity

        if index == original_index {
            return false
        }
    }
}

// hashset_remove removes a value from the set
hashset_remove :: proc(hs: ^HashSet($T), value: T) -> bool where T: comparable {
    index := hashset_hash(hs, value)
    original_index := index

    for {
        entry := &hs.entries[index]

        if !entry.occupied {
            return false
        }

        if !entry.deleted && entry.value == value {
            entry.deleted = true
            hs.size -= 1
            return true
        }

        index = (index + 1) % hs.capacity

        if index == original_index {
            return false
        }
    }
}

// hashset_len returns the number of elements
hashset_len :: proc(hs: ^HashSet($T)) -> int {
    return hs.size
}

// hashset_is_empty checks if the set is empty
hashset_is_empty :: proc(hs: ^HashSet($T)) -> bool {
    return hs.size == 0
}

// hashset_clear removes all elements
hashset_clear :: proc(hs: ^HashSet($T)) {
    for i := 0; i < hs.capacity; i += 1 {
        hs.entries[i].occupied = false
        hs.entries[i].deleted = false
    }
    hs.size = 0
}

// hashset_rehash resizes and rehashes the set
hashset_rehash :: proc(hs: ^HashSet($T)) where T: comparable {
    old_entries := hs.entries
    old_capacity := hs.capacity

    hs.capacity = hs.capacity * 2
    hs.entries = make([]HashSetEntry(T), hs.capacity, hs.allocator)
    hs.size = 0

    for i := 0; i < old_capacity; i += 1 {
        entry := &old_entries[i]
        if entry.occupied && !entry.deleted {
            hashset_insert(hs, entry.value)
        }
    }

    delete(old_entries)
}
