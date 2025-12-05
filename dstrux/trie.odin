package dstrux

import "core:mem"

// TrieNode represents a node in a trie
TrieNode :: struct {
    children: map[rune]^TrieNode,
    is_end_of_word: bool,
}

// Trie is a prefix tree for string operations
Trie :: struct {
    root: ^TrieNode,
    size: int,
    allocator: mem.Allocator,
}

// trie_make creates a new Trie
trie_make :: proc(allocator := context.allocator) -> Trie {
    root := new(TrieNode, allocator)
    root.children = make(map[rune]^TrieNode, allocator = allocator)
    root.is_end_of_word = false

    return Trie {
        root = root,
        size = 0,
        allocator = allocator,
    }
}

// trie_destroy frees the Trie
trie_destroy :: proc(trie: ^Trie) {
    _trie_destroy_node(trie, trie.root)
    trie.size = 0
}

_trie_destroy_node :: proc(trie: ^Trie, node: ^TrieNode) {
    if node == nil do return

    for _, child in node.children {
        _trie_destroy_node(trie, child)
    }

    delete(node.children)
    free(node, trie.allocator)
}

// trie_insert adds a word to the trie
trie_insert :: proc(trie: ^Trie, word: string) {
    node := trie.root

    for ch in word {
        if ch not_in node.children {
            new_node := new(TrieNode, trie.allocator)
            new_node.children = make(map[rune]^TrieNode, allocator = trie.allocator)
            new_node.is_end_of_word = false
            node.children[ch] = new_node
        }
        node = node.children[ch]
    }

    if !node.is_end_of_word {
        node.is_end_of_word = true
        trie.size += 1
    }
}

// trie_search checks if a word exists in the trie
trie_search :: proc(trie: ^Trie, word: string) -> bool {
    node := trie.root

    for ch in word {
        if ch not_in node.children {
            return false
        }
        node = node.children[ch]
    }

    return node.is_end_of_word
}

// trie_starts_with checks if any word in the trie starts with the given prefix
trie_starts_with :: proc(trie: ^Trie, prefix: string) -> bool {
    node := trie.root

    for ch in prefix {
        if ch not_in node.children {
            return false
        }
        node = node.children[ch]
    }

    return true
}

// trie_remove removes a word from the trie
trie_remove :: proc(trie: ^Trie, word: string) -> bool {
    return _trie_remove_helper(trie, trie.root, word, 0)
}

_trie_remove_helper :: proc(trie: ^Trie, node: ^TrieNode, word: string, index: int) -> bool {
    if node == nil do return false

    word_runes := make([dynamic]rune, context.temp_allocator)
    for ch in word do append(&word_runes, ch)

    if index == len(word_runes) {
        if !node.is_end_of_word {
            return false
        }
        node.is_end_of_word = false
        trie.size -= 1
        return len(node.children) == 0
    }

    ch := word_runes[index]
    child, exists := node.children[ch]
    if !exists {
        return false
    }

    should_delete := _trie_remove_helper(trie, child, word, index + 1)

    if should_delete {
        delete_key(&node.children, ch)
        free(child, trie.allocator)
        return len(node.children) == 0 && !node.is_end_of_word
    }

    return false
}

// trie_len returns the number of words in the trie
trie_len :: proc(trie: ^Trie) -> int {
    return trie.size
}

// trie_is_empty checks if the trie is empty
trie_is_empty :: proc(trie: ^Trie) -> bool {
    return trie.size == 0
}
