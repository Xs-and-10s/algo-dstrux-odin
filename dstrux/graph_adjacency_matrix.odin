package dstrux

import "core:mem"

// GraphAdjacencyMatrix is a graph using adjacency matrix representation
GraphAdjacencyMatrix :: struct($W: typeid) {
    matrix: [][]Maybe(W),
    num_vertices: int,
    directed: bool,
    allocator: mem.Allocator,
}

// graph_adj_matrix_make creates a new GraphAdjacencyMatrix
graph_adj_matrix_make :: proc($W: typeid, num_vertices: int, directed: bool = false, allocator := context.allocator) -> GraphAdjacencyMatrix(W) {
    matrix := make([][]Maybe(W), num_vertices, allocator)
    for i := 0; i < num_vertices; i += 1 {
        matrix[i] = make([]Maybe(W), num_vertices, allocator)
    }

    return GraphAdjacencyMatrix(W) {
        matrix = matrix,
        num_vertices = num_vertices,
        directed = directed,
        allocator = allocator,
    }
}

// graph_adj_matrix_destroy frees the GraphAdjacencyMatrix
graph_adj_matrix_destroy :: proc(graph: ^GraphAdjacencyMatrix($W)) {
    for i := 0; i < graph.num_vertices; i += 1 {
        delete(graph.matrix[i])
    }
    delete(graph.matrix)
}

// graph_adj_matrix_add_edge adds an edge to the graph
graph_adj_matrix_add_edge :: proc(graph: ^GraphAdjacencyMatrix($W), from, to: int, weight: W) {
    if from < 0 || from >= graph.num_vertices || to < 0 || to >= graph.num_vertices {
        return
    }

    graph.matrix[from][to] = weight

    if !graph.directed {
        graph.matrix[to][from] = weight
    }
}

// graph_adj_matrix_remove_edge removes an edge from the graph
graph_adj_matrix_remove_edge :: proc(graph: ^GraphAdjacencyMatrix($W), from, to: int) -> bool {
    if from < 0 || from >= graph.num_vertices || to < 0 || to >= graph.num_vertices {
        return false
    }

    had_edge := graph.matrix[from][to] != nil

    graph.matrix[from][to] = nil

    if !graph.directed {
        graph.matrix[to][from] = nil
    }

    return had_edge
}

// graph_adj_matrix_has_edge checks if an edge exists
graph_adj_matrix_has_edge :: proc(graph: ^GraphAdjacencyMatrix($W), from, to: int) -> bool {
    if from < 0 || from >= graph.num_vertices || to < 0 || to >= graph.num_vertices {
        return false
    }

    return graph.matrix[from][to] != nil
}

// graph_adj_matrix_get_weight gets the weight of an edge
graph_adj_matrix_get_weight :: proc(graph: ^GraphAdjacencyMatrix($W), from, to: int) -> (W, bool) {
    if from < 0 || from >= graph.num_vertices || to < 0 || to >= graph.num_vertices {
        return {}, false
    }

    if weight, ok := graph.matrix[from][to].?; ok {
        return weight, true
    }

    return {}, false
}

// graph_adj_matrix_num_vertices returns the number of vertices
graph_adj_matrix_num_vertices :: proc(graph: ^GraphAdjacencyMatrix($W)) -> int {
    return graph.num_vertices
}

// graph_adj_matrix_num_edges returns the number of edges
graph_adj_matrix_num_edges :: proc(graph: ^GraphAdjacencyMatrix($W)) -> int {
    count := 0
    for i := 0; i < graph.num_vertices; i += 1 {
        for j := 0; j < graph.num_vertices; j += 1 {
            if graph.matrix[i][j] != nil {
                count += 1
            }
        }
    }

    if !graph.directed {
        count /= 2
    }

    return count
}
