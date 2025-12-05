package dstrux

import "core:mem"

// GraphAdjacencyListEdge represents an edge in an adjacency list graph
GraphAdjacencyListEdge :: struct($W: typeid) {
    to: int,
    weight: W,
}

// GraphAdjacencyList is a graph using adjacency list representation
GraphAdjacencyList :: struct($W: typeid) {
    adj_list: [dynamic][dynamic]GraphAdjacencyListEdge(W),
    num_vertices: int,
    directed: bool,
    allocator: mem.Allocator,
}

// graph_adj_list_make creates a new GraphAdjacencyList
graph_adj_list_make :: proc($W: typeid, num_vertices: int, directed: bool = false, allocator := context.allocator) -> GraphAdjacencyList(W) {
    adj_list := make([dynamic][dynamic]GraphAdjacencyListEdge(W), num_vertices, allocator)
    for i := 0; i < num_vertices; i += 1 {
        adj_list[i] = make([dynamic]GraphAdjacencyListEdge(W), allocator)
    }

    return GraphAdjacencyList(W) {
        adj_list = adj_list,
        num_vertices = num_vertices,
        directed = directed,
        allocator = allocator,
    }
}

// graph_adj_list_destroy frees the GraphAdjacencyList
graph_adj_list_destroy :: proc(graph: ^GraphAdjacencyList($W)) {
    for i := 0; i < graph.num_vertices; i += 1 {
        delete(graph.adj_list[i])
    }
    delete(graph.adj_list)
}

// graph_adj_list_add_edge adds an edge to the graph
graph_adj_list_add_edge :: proc(graph: ^GraphAdjacencyList($W), from, to: int, weight: W) {
    if from < 0 || from >= graph.num_vertices || to < 0 || to >= graph.num_vertices {
        return
    }

    edge := GraphAdjacencyListEdge(W) {
        to = to,
        weight = weight,
    }

    append(&graph.adj_list[from], edge)

    if !graph.directed {
        reverse_edge := GraphAdjacencyListEdge(W) {
            to = from,
            weight = weight,
        }
        append(&graph.adj_list[to], reverse_edge)
    }
}

// graph_adj_list_remove_edge removes an edge from the graph
graph_adj_list_remove_edge :: proc(graph: ^GraphAdjacencyList($W), from, to: int) -> bool {
    if from < 0 || from >= graph.num_vertices || to < 0 || to >= graph.num_vertices {
        return false
    }

    found := false

    // Remove edge from -> to
    for i := 0; i < len(graph.adj_list[from]); i += 1 {
        if graph.adj_list[from][i].to == to {
            ordered_remove(&graph.adj_list[from], i)
            found = true
            break
        }
    }

    // If undirected, also remove edge to -> from
    if !graph.directed {
        for i := 0; i < len(graph.adj_list[to]); i += 1 {
            if graph.adj_list[to][i].to == from {
                ordered_remove(&graph.adj_list[to], i)
                break
            }
        }
    }

    return found
}

// graph_adj_list_has_edge checks if an edge exists
graph_adj_list_has_edge :: proc(graph: ^GraphAdjacencyList($W), from, to: int) -> bool {
    if from < 0 || from >= graph.num_vertices || to < 0 || to >= graph.num_vertices {
        return false
    }

    for edge in graph.adj_list[from] {
        if edge.to == to {
            return true
        }
    }

    return false
}

// graph_adj_list_get_neighbors returns the neighbors of a vertex
graph_adj_list_get_neighbors :: proc(graph: ^GraphAdjacencyList($W), vertex: int) -> []GraphAdjacencyListEdge(W) {
    if vertex < 0 || vertex >= graph.num_vertices {
        return nil
    }
    return graph.adj_list[vertex][:]
}

// graph_adj_list_num_vertices returns the number of vertices
graph_adj_list_num_vertices :: proc(graph: ^GraphAdjacencyList($W)) -> int {
    return graph.num_vertices
}

// graph_adj_list_num_edges returns the number of edges
graph_adj_list_num_edges :: proc(graph: ^GraphAdjacencyList($W)) -> int {
    count := 0
    for i := 0; i < graph.num_vertices; i += 1 {
        count += len(graph.adj_list[i])
    }

    if !graph.directed {
        count /= 2
    }

    return count
}
