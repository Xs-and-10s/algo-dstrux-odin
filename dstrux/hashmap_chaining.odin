package dstrux

import "core:hash"
import "core:mem"

// HashMapChainingEntry represents a key-value pair in a chaining hashmap
HashMapChainingEntry :: struct($K, $V: typeid) {
	key:   K,
	value: V,
	next:  ^HashMapChainingEntry(K, V),
}

// HashMapChaining is a hashmap using separate chaining for collision resolution
HashMapChaining :: struct($K, $V: typeid) {
	buckets:   []^HashMapChainingEntry(K, V),
	size:      int,
	capacity:  int,
	allocator: mem.Allocator,
}

// hashmap_chaining_make creates a new HashMapChaining
hashmap_chaining_make :: proc(
	$K, $V: typeid,
	capacity: int = 16,
	allocator := context.allocator,
) -> HashMapChaining(K, V) {
	return HashMapChaining(K, V) {
		buckets = make([]^HashMapChainingEntry(K, V), capacity, allocator),
		size = 0,
		capacity = capacity,
		allocator = allocator,
	}
}

// hashmap_chaining_destroy frees the HashMapChaining
hashmap_chaining_destroy :: proc(hm: ^HashMapChaining($K, $V)) {
	for i := 0; i < hm.capacity; i += 1 {
		entry := hm.buckets[i]
		for entry != nil {
			next := entry.next
			free(entry, hm.allocator)
			entry = next
		}
	}
	delete(hm.buckets)
}

// hashmap_chaining_hash computes the hash for a key
hashmap_chaining_hash :: proc(hm: ^HashMapChaining($K, $V), key: K) -> int {
	h := hash.crc32(mem.any_to_bytes(key))
	return int(h) % hm.capacity
}

// hashmap_chaining_insert inserts or updates a key-value pair
hashmap_chaining_insert :: proc(hm: ^HashMapChaining($K, $V), key: K, value: V) {
	index := hashmap_chaining_hash(hm, key)

	// Check if key already exists
	entry := hm.buckets[index]
	for entry != nil {
		if entry.key == key {
			entry.value = value
			return
		}
		entry = entry.next
	}

	// Add new entry at the head of the chain
	new_entry := new(HashMapChainingEntry(K, V), hm.allocator)
	new_entry.key = key
	new_entry.value = value
	new_entry.next = hm.buckets[index]
	hm.buckets[index] = new_entry
	hm.size += 1

	// Rehash if load factor exceeds 0.75
	load_factor := f32(hm.size) / f32(hm.capacity)
	if load_factor > 0.75 {
		hashmap_chaining_rehash(hm)
	}
}

// hashmap_chaining_get retrieves the value for a key
hashmap_chaining_get :: proc(hm: ^HashMapChaining($K, $V), key: K) -> (V, bool) {
	index := hashmap_chaining_hash(hm, key)
	entry := hm.buckets[index]

	for entry != nil {
		if entry.key == key {
			return entry.value, true
		}
		entry = entry.next
	}

	return {}, false
}

// hashmap_chaining_remove removes a key-value pair
hashmap_chaining_remove :: proc(hm: ^HashMapChaining($K, $V), key: K) -> bool {
	index := hashmap_chaining_hash(hm, key)
	entry := hm.buckets[index]
	var; prev: ^HashMapChainingEntry(K, V) = nil

	for entry != nil {
		if entry.key == key {
			if prev == nil {
				hm.buckets[index] = entry.next
			} else {
				prev.next = entry.next
			}
			free(entry, hm.allocator)
			hm.size -= 1
			return true
		}
		prev = entry
		entry = entry.next
	}

	return false
}

// hashmap_chaining_contains checks if a key exists
hashmap_chaining_contains :: proc(hm: ^HashMapChaining($K, $V), key: K) -> bool {
	_, ok := hashmap_chaining_get(hm, key)
	return ok
}

// hashmap_chaining_len returns the number of key-value pairs
hashmap_chaining_len :: proc(hm: ^HashMapChaining($K, $V)) -> int {
	return hm.size
}

// hashmap_chaining_is_empty checks if the map is empty
hashmap_chaining_is_empty :: proc(hm: ^HashMapChaining($K, $V)) -> bool {
	return hm.size == 0
}

// hashmap_chaining_rehash resizes and rehashes the map
hashmap_chaining_rehash :: proc(hm: ^HashMapChaining($K, $V)) {
	old_buckets := hm.buckets
	old_capacity := hm.capacity

	hm.capacity = hm.capacity * 2
	hm.buckets = make([]^HashMapChainingEntry(K, V), hm.capacity, hm.allocator)
	hm.size = 0

	for i := 0; i < old_capacity; i += 1 {
		entry := old_buckets[i]
		for entry != nil {
			next := entry.next
			hashmap_chaining_insert(hm, entry.key, entry.value)
			free(entry, hm.allocator)
			entry = next
		}
	}

	delete(old_buckets)
}
