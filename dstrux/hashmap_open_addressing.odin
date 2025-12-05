package dstrux

import "core:mem"
import "core:hash"

// HashMapOpenAddressingEntry represents a key-value pair
HashMapOpenAddressingEntry :: struct($K, $V: typeid) {
    key: K,
    value: V,
    occupied: bool,
    deleted: bool,
}

// HashMapOpenAddressing is a hashmap using open addressing (linear probing)
HashMapOpenAddressing :: struct($K, $V: typeid) {
    entries: []HashMapOpenAddressingEntry(K, V),
    size: int,
    capacity: int,
    allocator: mem.Allocator,
}

// hashmap_open_make creates a new HashMapOpenAddressing
hashmap_open_make :: proc($K, $V: typeid, capacity: int = 16, allocator := context.allocator) -> HashMapOpenAddressing(K, V) {
    return HashMapOpenAddressing(K, V) {
        entries = make([]HashMapOpenAddressingEntry(K, V), capacity, allocator),
        size = 0,
        capacity = capacity,
        allocator = allocator,
    }
}

// hashmap_open_destroy frees the HashMapOpenAddressing
hashmap_open_destroy :: proc(hm: ^HashMapOpenAddressing($K, $V)) {
    delete(hm.entries)
}

// hashmap_open_hash computes the hash for a key
hashmap_open_hash :: proc(hm: ^HashMapOpenAddressing($K, $V), key: K) -> int {
    h := hash.crc32(mem.any_to_bytes(key))
    return int(h) % hm.capacity
}

// hashmap_open_insert inserts or updates a key-value pair
hashmap_open_insert :: proc(hm: ^HashMapOpenAddressing($K, $V), key: K, value: V) where K: comparable {
    // Rehash if load factor exceeds 0.7
    load_factor := f32(hm.size) / f32(hm.capacity)
    if load_factor > 0.7 {
        hashmap_open_rehash(hm)
    }

    index := hashmap_open_hash(hm, key)
    original_index := index

    for {
        entry := &hm.entries[index]

        if !entry.occupied || entry.deleted {
            // Found an empty or deleted slot
            entry.key = key
            entry.value = value
            entry.occupied = true
            entry.deleted = false
            hm.size += 1
            return
        }

        if entry.key == key {
            // Key already exists, update value
            entry.value = value
            return
        }

        // Linear probing
        index = (index + 1) % hm.capacity

        // Should never happen if load factor is maintained correctly
        if index == original_index {
            panic("HashMap is full (this should not happen)")
        }
    }
}

// hashmap_open_get retrieves the value for a key
hashmap_open_get :: proc(hm: ^HashMapOpenAddressing($K, $V), key: K) -> (V, bool) where K: comparable {
    index := hashmap_open_hash(hm, key)
    original_index := index

    for {
        entry := &hm.entries[index]

        if !entry.occupied {
            // Empty slot, key not found
            return {}, false
        }

        if !entry.deleted && entry.key == key {
            // Found the key
            return entry.value, true
        }

        // Linear probing
        index = (index + 1) % hm.capacity

        if index == original_index {
            // Wrapped around, key not found
            return {}, false
        }
    }
}

// hashmap_open_remove removes a key-value pair
hashmap_open_remove :: proc(hm: ^HashMapOpenAddressing($K, $V), key: K) -> bool where K: comparable {
    index := hashmap_open_hash(hm, key)
    original_index := index

    for {
        entry := &hm.entries[index]

        if !entry.occupied {
            // Empty slot, key not found
            return false
        }

        if !entry.deleted && entry.key == key {
            // Found the key, mark as deleted
            entry.deleted = true
            hm.size -= 1
            return true
        }

        // Linear probing
        index = (index + 1) % hm.capacity

        if index == original_index {
            // Wrapped around, key not found
            return false
        }
    }
}

// hashmap_open_contains checks if a key exists
hashmap_open_contains :: proc(hm: ^HashMapOpenAddressing($K, $V), key: K) -> bool where K: comparable {
    _, ok := hashmap_open_get(hm, key)
    return ok
}

// hashmap_open_len returns the number of key-value pairs
hashmap_open_len :: proc(hm: ^HashMapOpenAddressing($K, $V)) -> int {
    return hm.size
}

// hashmap_open_is_empty checks if the map is empty
hashmap_open_is_empty :: proc(hm: ^HashMapOpenAddressing($K, $V)) -> bool {
    return hm.size == 0
}

// hashmap_open_rehash resizes and rehashes the map
hashmap_open_rehash :: proc(hm: ^HashMapOpenAddressing($K, $V)) where K: comparable {
    old_entries := hm.entries
    old_capacity := hm.capacity

    hm.capacity = hm.capacity * 2
    hm.entries = make([]HashMapOpenAddressingEntry(K, V), hm.capacity, hm.allocator)
    hm.size = 0

    for i := 0; i < old_capacity; i += 1 {
        entry := &old_entries[i]
        if entry.occupied && !entry.deleted {
            hashmap_open_insert(hm, entry.key, entry.value)
        }
    }

    delete(old_entries)
}
