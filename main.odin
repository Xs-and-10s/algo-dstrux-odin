package main

import "core:fmt"
import "dstrux"

main :: proc() {
    fmt.println("=== Odin Data Structures Library Demo ===\n")

    demo_arraylist()
    demo_stack()
    demo_queue()
    demo_deque()
    demo_singly_linked_list()
    demo_doubly_linked_list()
    demo_ring_buffer()
    demo_hashmap_chaining()
    demo_hashmap_open_addressing()
    demo_hashset()
    demo_binary_search_tree()
    demo_avl_tree()
    demo_red_black_tree()
    demo_trie()
    demo_interval_tree()
    demo_segment_tree()
    demo_binary_heap()
    demo_minmax_heap()
    demo_rope()
    demo_graph_adjacency_list()
    demo_graph_adjacency_matrix()
    demo_disjoint_set()
    demo_bloom_filter()
    demo_skip_list()
    demo_btree()

    fmt.println("\n=== All demos completed successfully! ===")
}

demo_arraylist :: proc() {
    fmt.println("--- ArrayList ---")
    list := dstrux.arraylist_make(int)
    defer dstrux.arraylist_destroy(&list)

    dstrux.arraylist_append(&list, 10)
    dstrux.arraylist_append(&list, 20)
    dstrux.arraylist_append(&list, 30)

    fmt.printf("ArrayList length: %d\n", dstrux.arraylist_len(&list))
    if val, ok := dstrux.arraylist_get(&list, 1); ok {
        fmt.printf("Element at index 1: %d\n", val)
    }
    fmt.println()
}

demo_stack :: proc() {
    fmt.println("--- Stack ---")
    stack := dstrux.stack_make(int)
    defer dstrux.stack_destroy(&stack)

    dstrux.stack_push(&stack, 1)
    dstrux.stack_push(&stack, 2)
    dstrux.stack_push(&stack, 3)

    if val, ok := dstrux.stack_pop(&stack); ok {
        fmt.printf("Popped: %d\n", val)
    }
    fmt.printf("Stack size: %d\n", dstrux.stack_len(&stack))
    fmt.println()
}

demo_queue :: proc() {
    fmt.println("--- Queue ---")
    queue := dstrux.queue_make(int)
    defer dstrux.queue_destroy(&queue)

    dstrux.queue_enqueue(&queue, 1)
    dstrux.queue_enqueue(&queue, 2)
    dstrux.queue_enqueue(&queue, 3)

    if val, ok := dstrux.queue_dequeue(&queue); ok {
        fmt.printf("Dequeued: %d\n", val)
    }
    fmt.printf("Queue size: %d\n", dstrux.queue_len(&queue))
    fmt.println()
}

demo_deque :: proc() {
    fmt.println("--- Deque ---")
    deque := dstrux.deque_make(int)
    defer dstrux.deque_destroy(&deque)

    dstrux.deque_push_back(&deque, 1)
    dstrux.deque_push_front(&deque, 2)
    dstrux.deque_push_back(&deque, 3)

    if val, ok := dstrux.deque_pop_front(&deque); ok {
        fmt.printf("Popped from front: %d\n", val)
    }
    fmt.printf("Deque size: %d\n", dstrux.deque_len(&deque))
    fmt.println()
}

demo_singly_linked_list :: proc() {
    fmt.println("--- SinglyLinkedList ---")
    list := dstrux.sll_make(int)
    defer dstrux.sll_destroy(&list)

    dstrux.sll_push_back(&list, 10)
    dstrux.sll_push_back(&list, 20)
    dstrux.sll_push_front(&list, 5)

    fmt.printf("List length: %d\n", dstrux.sll_len(&list))
    if val, ok := dstrux.sll_peek_front(&list); ok {
        fmt.printf("Front value: %d\n", val)
    }
    fmt.println()
}

demo_doubly_linked_list :: proc() {
    fmt.println("--- DoublyLinkedList ---")
    list := dstrux.dll_make(int)
    defer dstrux.dll_destroy(&list)

    dstrux.dll_push_back(&list, 10)
    dstrux.dll_push_back(&list, 20)
    dstrux.dll_push_front(&list, 5)

    fmt.printf("List length: %d\n", dstrux.dll_len(&list))
    if val, ok := dstrux.dll_peek_back(&list); ok {
        fmt.printf("Back value: %d\n", val)
    }
    fmt.println()
}

demo_ring_buffer :: proc() {
    fmt.println("--- RingBuffer ---")
    rb := dstrux.ring_buffer_make(int, 5)
    defer dstrux.ring_buffer_destroy(&rb)

    for i in 1..=7 {
        dstrux.ring_buffer_push(&rb, i)
    }

    fmt.printf("Ring buffer size: %d\n", dstrux.ring_buffer_len(&rb))
    if val, ok := dstrux.ring_buffer_peek(&rb); ok {
        fmt.printf("Oldest value: %d\n", val)
    }
    fmt.println()
}

demo_hashmap_chaining :: proc() {
    fmt.println("--- HashMap (Chaining) ---")
    hm := dstrux.hashmap_chaining_make(int, string)
    defer dstrux.hashmap_chaining_destroy(&hm)

    dstrux.hashmap_chaining_insert(&hm, 1, "one")
    dstrux.hashmap_chaining_insert(&hm, 2, "two")
    dstrux.hashmap_chaining_insert(&hm, 3, "three")

    if val, ok := dstrux.hashmap_chaining_get(&hm, 2); ok {
        fmt.printf("Key 2: %s\n", val)
    }
    fmt.printf("HashMap size: %d\n", dstrux.hashmap_chaining_len(&hm))
    fmt.println()
}

demo_hashmap_open_addressing :: proc() {
    fmt.println("--- HashMap (Open Addressing) ---")
    hm := dstrux.hashmap_open_make(int, string)
    defer dstrux.hashmap_open_destroy(&hm)

    dstrux.hashmap_open_insert(&hm, 1, "one")
    dstrux.hashmap_open_insert(&hm, 2, "two")
    dstrux.hashmap_open_insert(&hm, 3, "three")

    if val, ok := dstrux.hashmap_open_get(&hm, 2); ok {
        fmt.printf("Key 2: %s\n", val)
    }
    fmt.printf("HashMap size: %d\n", dstrux.hashmap_open_len(&hm))
    fmt.println()
}

demo_hashset :: proc() {
    fmt.println("--- HashSet ---")
    hs := dstrux.hashset_make(int)
    defer dstrux.hashset_destroy(&hs)

    dstrux.hashset_insert(&hs, 10)
    dstrux.hashset_insert(&hs, 20)
    dstrux.hashset_insert(&hs, 30)

    fmt.printf("Contains 20: %v\n", dstrux.hashset_contains(&hs, 20))
    fmt.printf("Contains 40: %v\n", dstrux.hashset_contains(&hs, 40))
    fmt.printf("HashSet size: %d\n", dstrux.hashset_len(&hs))
    fmt.println()
}

demo_binary_search_tree :: proc() {
    fmt.println("--- Binary Search Tree ---")
    tree := dstrux.bst_make(int)
    defer dstrux.bst_destroy(&tree)

    dstrux.bst_insert(&tree, 50)
    dstrux.bst_insert(&tree, 30)
    dstrux.bst_insert(&tree, 70)
    dstrux.bst_insert(&tree, 20)
    dstrux.bst_insert(&tree, 40)

    fmt.printf("Contains 30: %v\n", dstrux.bst_search(&tree, 30))
    fmt.printf("Contains 60: %v\n", dstrux.bst_search(&tree, 60))
    fmt.printf("Tree size: %d\n", dstrux.bst_len(&tree))
    fmt.println()
}

demo_avl_tree :: proc() {
    fmt.println("--- AVL Tree ---")
    tree := dstrux.avl_make(int)
    defer dstrux.avl_destroy(&tree)

    dstrux.avl_insert(&tree, 50)
    dstrux.avl_insert(&tree, 30)
    dstrux.avl_insert(&tree, 70)
    dstrux.avl_insert(&tree, 20)
    dstrux.avl_insert(&tree, 40)

    fmt.printf("Contains 30: %v\n", dstrux.avl_search(&tree, 30))
    fmt.printf("Tree height: %d\n", dstrux.avl_height(&tree))
    fmt.printf("Tree size: %d\n", dstrux.avl_len(&tree))
    fmt.println()
}

demo_red_black_tree :: proc() {
    fmt.println("--- Red-Black Tree ---")
    tree := dstrux.rbt_make(int)
    defer dstrux.rbt_destroy(&tree)

    dstrux.rbt_insert(&tree, 50)
    dstrux.rbt_insert(&tree, 30)
    dstrux.rbt_insert(&tree, 70)
    dstrux.rbt_insert(&tree, 20)
    dstrux.rbt_insert(&tree, 40)

    fmt.printf("Contains 30: %v\n", dstrux.rbt_search(&tree, 30))
    fmt.printf("Tree size: %d\n", dstrux.rbt_len(&tree))
    fmt.println()
}

demo_trie :: proc() {
    fmt.println("--- Trie ---")
    trie := dstrux.trie_make()
    defer dstrux.trie_destroy(&trie)

    dstrux.trie_insert(&trie, "hello")
    dstrux.trie_insert(&trie, "world")
    dstrux.trie_insert(&trie, "hell")

    fmt.printf("Contains 'hello': %v\n", dstrux.trie_search(&trie, "hello"))
    fmt.printf("Starts with 'hel': %v\n", dstrux.trie_starts_with(&trie, "hel"))
    fmt.printf("Trie size: %d\n", dstrux.trie_len(&trie))
    fmt.println()
}

demo_interval_tree :: proc() {
    fmt.println("--- Interval Tree ---")
    tree := dstrux.interval_tree_make(int)
    defer dstrux.interval_tree_destroy(&tree)

    dstrux.interval_tree_insert(&tree, dstrux.Interval(int){15, 20})
    dstrux.interval_tree_insert(&tree, dstrux.Interval(int){10, 30})
    dstrux.interval_tree_insert(&tree, dstrux.Interval(int){17, 19})

    if interval, ok := dstrux.interval_tree_search(&tree, dstrux.Interval(int){14, 16}); ok {
        fmt.printf("Found overlapping interval: [%d, %d]\n", interval.low, interval.high)
    }
    fmt.printf("Tree size: %d\n", dstrux.interval_tree_len(&tree))
    fmt.println()
}

demo_segment_tree :: proc() {
    fmt.println("--- Segment Tree ---")
    data := []int{1, 3, 5, 7, 9, 11}
    sum_combine :: proc(a, b: int) -> int { return a + b }

    st := dstrux.segment_tree_make(int, data, sum_combine)
    defer dstrux.segment_tree_destroy(&st)

    sum := dstrux.segment_tree_query(&st, 1, 3)
    fmt.printf("Sum of range [1, 3]: %d\n", sum)

    dstrux.segment_tree_update(&st, 1, 10)
    sum = dstrux.segment_tree_query(&st, 1, 3)
    fmt.printf("Sum after update: %d\n", sum)
    fmt.println()
}

demo_binary_heap :: proc() {
    fmt.println("--- Binary Heap (Min) ---")
    heap := dstrux.binary_heap_make(int, .Min)
    defer dstrux.binary_heap_destroy(&heap)

    dstrux.binary_heap_push(&heap, 5)
    dstrux.binary_heap_push(&heap, 3)
    dstrux.binary_heap_push(&heap, 7)
    dstrux.binary_heap_push(&heap, 1)

    if val, ok := dstrux.binary_heap_pop(&heap); ok {
        fmt.printf("Min value: %d\n", val)
    }
    fmt.printf("Heap size: %d\n", dstrux.binary_heap_len(&heap))
    fmt.println()
}

demo_minmax_heap :: proc() {
    fmt.println("--- MinMax Heap ---")
    heap := dstrux.minmax_heap_make(int)
    defer dstrux.minmax_heap_destroy(&heap)

    dstrux.minmax_heap_push(&heap, 5)
    dstrux.minmax_heap_push(&heap, 3)
    dstrux.minmax_heap_push(&heap, 7)
    dstrux.minmax_heap_push(&heap, 1)
    dstrux.minmax_heap_push(&heap, 9)

    if min_val, ok := dstrux.minmax_heap_peek_min(&heap); ok {
        fmt.printf("Min value: %d\n", min_val)
    }
    if max_val, ok := dstrux.minmax_heap_peek_max(&heap); ok {
        fmt.printf("Max value: %d\n", max_val)
    }
    fmt.printf("Heap size: %d\n", dstrux.minmax_heap_len(&heap))
    fmt.println()
}

demo_rope :: proc() {
    fmt.println("--- Rope ---")
    rope := dstrux.rope_make("Hello, World!")
    defer dstrux.rope_destroy(&rope)

    fmt.printf("Rope length: %d\n", dstrux.rope_length(&rope))

    if ch, ok := dstrux.rope_index(&rope, 7); ok {
        fmt.printf("Character at index 7: %c\n", ch)
    }

    substring := dstrux.rope_substring(&rope, 0, 5)
    defer delete(substring)
    fmt.printf("Substring [0, 5): %s\n", substring)
    fmt.println()
}

demo_graph_adjacency_list :: proc() {
    fmt.println("--- Graph (Adjacency List) ---")
    graph := dstrux.graph_adj_list_make(int, 5, false)
    defer dstrux.graph_adj_list_destroy(&graph)

    dstrux.graph_adj_list_add_edge(&graph, 0, 1, 10)
    dstrux.graph_adj_list_add_edge(&graph, 0, 2, 5)
    dstrux.graph_adj_list_add_edge(&graph, 1, 2, 3)

    fmt.printf("Has edge 0->1: %v\n", dstrux.graph_adj_list_has_edge(&graph, 0, 1))
    fmt.printf("Number of edges: %d\n", dstrux.graph_adj_list_num_edges(&graph))
    fmt.println()
}

demo_graph_adjacency_matrix :: proc() {
    fmt.println("--- Graph (Adjacency Matrix) ---")
    graph := dstrux.graph_adj_matrix_make(int, 5, false)
    defer dstrux.graph_adj_matrix_destroy(&graph)

    dstrux.graph_adj_matrix_add_edge(&graph, 0, 1, 10)
    dstrux.graph_adj_matrix_add_edge(&graph, 0, 2, 5)
    dstrux.graph_adj_matrix_add_edge(&graph, 1, 2, 3)

    fmt.printf("Has edge 0->1: %v\n", dstrux.graph_adj_matrix_has_edge(&graph, 0, 1))
    if weight, ok := dstrux.graph_adj_matrix_get_weight(&graph, 0, 1); ok {
        fmt.printf("Weight of edge 0->1: %d\n", weight)
    }
    fmt.println()
}

demo_disjoint_set :: proc() {
    fmt.println("--- Disjoint Set (Union-Find) ---")
    ds := dstrux.disjoint_set_make(10)
    defer dstrux.disjoint_set_destroy(&ds)

    dstrux.disjoint_set_union(&ds, 0, 1)
    dstrux.disjoint_set_union(&ds, 1, 2)
    dstrux.disjoint_set_union(&ds, 3, 4)

    fmt.printf("0 and 2 connected: %v\n", dstrux.disjoint_set_connected(&ds, 0, 2))
    fmt.printf("0 and 3 connected: %v\n", dstrux.disjoint_set_connected(&ds, 0, 3))
    fmt.printf("Number of sets: %d\n", dstrux.disjoint_set_count(&ds))
    fmt.println()
}

demo_bloom_filter :: proc() {
    fmt.println("--- Bloom Filter ---")
    bf := dstrux.bloom_filter_make(1000, 3)
    defer dstrux.bloom_filter_destroy(&bf)

    dstrux.bloom_filter_add(&bf, transmute([]byte)string("hello"))
    dstrux.bloom_filter_add(&bf, transmute([]byte)string("world"))

    fmt.printf("Contains 'hello': %v\n", dstrux.bloom_filter_contains(&bf, transmute([]byte)string("hello")))
    fmt.printf("Contains 'test': %v\n", dstrux.bloom_filter_contains(&bf, transmute([]byte)string("test")))
    fmt.println()
}

demo_skip_list :: proc() {
    fmt.println("--- Skip List ---")
    list := dstrux.skip_list_make(int)
    defer dstrux.skip_list_destroy(&list)

    dstrux.skip_list_insert(&list, 5)
    dstrux.skip_list_insert(&list, 3)
    dstrux.skip_list_insert(&list, 7)
    dstrux.skip_list_insert(&list, 1)

    fmt.printf("Contains 3: %v\n", dstrux.skip_list_search(&list, 3))
    fmt.printf("Contains 4: %v\n", dstrux.skip_list_search(&list, 4))
    fmt.printf("Skip list size: %d\n", dstrux.skip_list_len(&list))
    fmt.println()
}

demo_btree :: proc() {
    fmt.println("--- B-Tree ---")
    tree := dstrux.btree_make(int, 5)
    defer dstrux.btree_destroy(&tree)

    dstrux.btree_insert(&tree, 10)
    dstrux.btree_insert(&tree, 20)
    dstrux.btree_insert(&tree, 5)
    dstrux.btree_insert(&tree, 15)
    dstrux.btree_insert(&tree, 25)

    fmt.printf("Contains 15: %v\n", dstrux.btree_search(&tree, 15))
    fmt.printf("Contains 30: %v\n", dstrux.btree_search(&tree, 30))
    fmt.printf("B-Tree size: %d\n", dstrux.btree_len(&tree))
    fmt.println()
}
