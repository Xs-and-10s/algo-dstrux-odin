package dstrux

import "core:mem"
import "core:hash"

// BloomFilter is a probabilistic data structure for set membership
BloomFilter :: struct {
    bits: []bool,
    size: int,
    num_hashes: int,
    allocator: mem.Allocator,
}

// bloom_filter_make creates a new BloomFilter
bloom_filter_make :: proc(size: int, num_hashes: int = 3, allocator := context.allocator) -> BloomFilter {
    return BloomFilter {
        bits = make([]bool, size, allocator),
        size = size,
        num_hashes = num_hashes,
        allocator = allocator,
    }
}

// bloom_filter_destroy frees the BloomFilter
bloom_filter_destroy :: proc(bf: ^BloomFilter) {
    delete(bf.bits)
}

// bloom_filter_hash computes the i-th hash for a value
_bloom_filter_hash :: proc(bf: ^BloomFilter, data: []byte, i: int) -> int {
    // Combine multiple hash functions using different seeds
    h := hash.crc32(data)
    h = h ~ u32(i * 0x9e3779b9) // Mix with golden ratio
    return int(h) % bf.size
}

// bloom_filter_add adds an element to the filter
bloom_filter_add :: proc(bf: ^BloomFilter, data: []byte) {
    for i := 0; i < bf.num_hashes; i += 1 {
        index := _bloom_filter_hash(bf, data, i)
        bf.bits[index] = true
    }
}

// bloom_filter_contains checks if an element might be in the filter
bloom_filter_contains :: proc(bf: ^BloomFilter, data: []byte) -> bool {
    for i := 0; i < bf.num_hashes; i += 1 {
        index := _bloom_filter_hash(bf, data, i)
        if !bf.bits[index] {
            return false
        }
    }
    return true
}

// bloom_filter_clear resets the filter
bloom_filter_clear :: proc(bf: ^BloomFilter) {
    for i := 0; i < bf.size; i += 1 {
        bf.bits[i] = false
    }
}
