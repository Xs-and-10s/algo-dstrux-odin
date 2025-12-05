# algo-dstrux-odin

A comprehensive collection of data structures implemented in Odin programming language. This library provides efficient, well-tested implementations of common and exotic data structures for use in algorithms and DSA questions.

## Features

- **Type-safe** generic data structures using Odin's parametric polymorphism
- **Memory-efficient** implementations with custom allocator support
- **Single-file** data structures for easy importing
- **Library-ready** - can be imported into your main procedure or used as a standalone library
- **Comprehensive** - includes both common and exotic data structures

## Data Structures Included

### Basic Linear Structures
- **ArrayList** - Dynamic array with automatic resizing
- **Stack** - LIFO data structure
- **Queue** - FIFO data structure
- **Deque** - Double-ended queue
- **RingBuffer** - Fixed-size circular buffer

### Linked Lists
- **SinglyLinkedList** - Singly linked list
- **DoublyLinkedList** - Doubly linked list with bi-directional traversal

### Hash-Based Structures
- **HashMap (Chaining)** - Hash map using separate chaining for collision resolution
- **HashMap (Open Addressing)** - Hash map using linear probing
- **HashSet** - Set implementation using open addressing

### Tree Structures
- **BinarySearchTree** - Basic BST with insertion, deletion, and search
- **AVLTree** - Self-balancing binary search tree
- **RedBlackTree** - Self-balancing binary search tree with red-black properties
- **Trie** - Prefix tree for efficient string operations
- **IntervalTree** - Tree for storing and querying intervals
- **SegmentTree** - Tree for range queries and updates
- **BTree** - Self-balancing tree optimized for disk access

### Heap Structures
- **BinaryHeap** - Min/Max heap implementation
- **MinMaxHeap** - Double-ended priority queue

### String Structures
- **Rope** - Tree-based string structure for efficient string operations

### Graph Structures
- **GraphAdjacencyList** - Graph using adjacency list representation
- **GraphAdjacencyMatrix** - Graph using adjacency matrix representation

### Exotic Structures
- **DisjointSet (Union-Find)** - For tracking disjoint sets with path compression
- **BloomFilter** - Probabilistic set membership data structure
- **SkipList** - Probabilistic alternative to balanced trees
- **BTree** - Self-balancing tree for external storage

## Installation

Clone this repository:
```bash
git clone https://github.com/Xs-and-10s/algo-dstrux-odin.git
cd algo-dstrux-odin
```

## Usage

### As a Library

Import the `dstrux` package in your Odin code:

```odin
package main

import "dstrux"
import "core:fmt"

main :: proc() {
    // Create an ArrayList
    list := dstrux.arraylist_make(int)
    defer dstrux.arraylist_destroy(&list)

    dstrux.arraylist_append(&list, 10)
    dstrux.arraylist_append(&list, 20)
    dstrux.arraylist_append(&list, 30)

    fmt.printf("List length: %d\n", dstrux.arraylist_len(&list))
}
```

### Running the Demo

Compile and run the main program to see all data structures in action:

```bash
odin run .
```

## Examples

### ArrayList
```odin
list := dstrux.arraylist_make(int)
defer dstrux.arraylist_destroy(&list)

dstrux.arraylist_append(&list, 42)
dstrux.arraylist_insert(&list, 0, 10)
val, ok := dstrux.arraylist_get(&list, 0)
```

### Stack
```odin
stack := dstrux.stack_make(string)
defer dstrux.stack_destroy(&stack)

dstrux.stack_push(&stack, "first")
dstrux.stack_push(&stack, "second")
val, ok := dstrux.stack_pop(&stack)
```

### HashMap (Chaining)
```odin
hm := dstrux.hashmap_chaining_make(int, string)
defer dstrux.hashmap_chaining_destroy(&hm)

dstrux.hashmap_chaining_insert(&hm, 1, "one")
dstrux.hashmap_chaining_insert(&hm, 2, "two")
val, ok := dstrux.hashmap_chaining_get(&hm, 1)
```

### Binary Search Tree
```odin
tree := dstrux.bst_make(int)
defer dstrux.bst_destroy(&tree)

dstrux.bst_insert(&tree, 50)
dstrux.bst_insert(&tree, 30)
dstrux.bst_insert(&tree, 70)
found := dstrux.bst_search(&tree, 30)
```

### AVL Tree
```odin
tree := dstrux.avl_make(int)
defer dstrux.avl_destroy(&tree)

dstrux.avl_insert(&tree, 10)
dstrux.avl_insert(&tree, 20)
dstrux.avl_insert(&tree, 30)
height := dstrux.avl_height(&tree)
```

### Trie
```odin
trie := dstrux.trie_make()
defer dstrux.trie_destroy(&trie)

dstrux.trie_insert(&trie, "hello")
dstrux.trie_insert(&trie, "world")
found := dstrux.trie_search(&trie, "hello")
has_prefix := dstrux.trie_starts_with(&trie, "hel")
```

### Binary Heap
```odin
heap := dstrux.binary_heap_make(int, .Min)
defer dstrux.binary_heap_destroy(&heap)

dstrux.binary_heap_push(&heap, 5)
dstrux.binary_heap_push(&heap, 3)
dstrux.binary_heap_push(&heap, 7)
min_val, ok := dstrux.binary_heap_pop(&heap)
```

### Graph (Adjacency List)
```odin
graph := dstrux.graph_adj_list_make(int, 5, false)
defer dstrux.graph_adj_list_destroy(&graph)

dstrux.graph_adj_list_add_edge(&graph, 0, 1, 10)
dstrux.graph_adj_list_add_edge(&graph, 1, 2, 5)
has_edge := dstrux.graph_adj_list_has_edge(&graph, 0, 1)
```

### Disjoint Set (Union-Find)
```odin
ds := dstrux.disjoint_set_make(10)
defer dstrux.disjoint_set_destroy(&ds)

dstrux.disjoint_set_union(&ds, 0, 1)
dstrux.disjoint_set_union(&ds, 1, 2)
connected := dstrux.disjoint_set_connected(&ds, 0, 2)
```

### Bloom Filter
```odin
bf := dstrux.bloom_filter_make(1000, 3)
defer dstrux.bloom_filter_destroy(&bf)

dstrux.bloom_filter_add(&bf, transmute([]byte)string("hello"))
might_contain := dstrux.bloom_filter_contains(&bf, transmute([]byte)string("hello"))
```

## API Conventions

- All data structures use the `make` pattern for creation (e.g., `arraylist_make`, `stack_make`)
- All data structures have a corresponding `destroy` function to free resources
- Most functions return `(value, bool)` tuples where the boolean indicates success
- Generic data structures use Odin's `$T: typeid` syntax for type parameters
- Custom allocators can be passed to `make` functions

## Memory Management

All data structures support custom allocators. By default, they use `context.allocator`. Always call the corresponding `destroy` function to free memory:

```odin
list := dstrux.arraylist_make(int)
defer dstrux.arraylist_destroy(&list)  // Good practice
```

## Project Structure

```
algo-dstrux-odin/
├── dstrux/                 # Data structures library
│   ├── arraylist.odin
│   ├── stack.odin
│   ├── queue.odin
│   ├── deque.odin
│   ├── singly_linked_list.odin
│   ├── doubly_linked_list.odin
│   ├── ring_buffer.odin
│   ├── hashmap_chaining.odin
│   ├── hashmap_open_addressing.odin
│   ├── hashset.odin
│   ├── binary_search_tree.odin
│   ├── avl_tree.odin
│   ├── red_black_tree.odin
│   ├── trie.odin
│   ├── interval_tree.odin
│   ├── segment_tree.odin
│   ├── binary_heap.odin
│   ├── minmax_heap.odin
│   ├── rope.odin
│   ├── graph_adjacency_list.odin
│   ├── graph_adjacency_matrix.odin
│   ├── disjoint_set.odin
│   ├── bloom_filter.odin
│   ├── skip_list.odin
│   └── btree.odin
├── main.odin              # Demo program
├── README.md              # This file
└── LICENSE
```

## Requirements

- Odin compiler (latest version recommended)
- Tested on Linux, should work on macOS and Windows

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new data structures
- Improve existing implementations
- Add more examples

## License

This project is open source. See LICENSE file for details.

## Acknowledgments

Implemented in Odin, a fast, concise, readable, pragmatic programming language.

## Learn More

- [Odin Language](https://odin-lang.org/)
- [Odin Documentation](https://odin-lang.org/docs/)
