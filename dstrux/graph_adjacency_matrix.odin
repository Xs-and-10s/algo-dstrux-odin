package dstrux

import "core:mem"

// GraphAdjacencyMatrix is a graph using adjacency matrix representation
// Uses a flattened 1D array to store the 2D matrix
GraphAdjacencyMatrix :: struct($W: typeid) {
	data:         [dynamic]Maybe(W),
	num_vertices: int,
	directed:     bool,
	allocator:    mem.Allocator,
}

// graph_adj_matrix_make creates a new GraphAdjacencyMatrix
graph_adj_matrix_make :: proc(
	$W: typeid,
	num_vertices: int,
	directed: bool = false,
	allocator := context.allocator,
) -> GraphAdjacencyMatrix(W) {
	size := num_vertices * num_vertices
	data := make([dynamic]Maybe(W), size, allocator)

	return GraphAdjacencyMatrix(W) {
		data = data,
		num_vertices = num_vertices,
		directed = directed,
		allocator = allocator,
	}
}

// graph_adj_matrix_destroy frees the GraphAdjacencyMatrix
graph_adj_matrix_destroy :: proc(graph: ^GraphAdjacencyMatrix($W)) {
	delete(graph.data)
}

// Helper to convert 2D indices to 1D index
_graph_adj_matrix_index :: proc(graph: ^GraphAdjacencyMatrix($W), row, col: int) -> int {
	return row * graph.num_vertices + col
}

// graph_adj_matrix_add_edge adds an edge to the graph
graph_adj_matrix_add_edge :: proc(graph: ^GraphAdjacencyMatrix($W), from, to: int, weight: W) {
	if from < 0 || from >= graph.num_vertices || to < 0 || to >= graph.num_vertices {
		return
	}

	idx := _graph_adj_matrix_index(graph, from, to)
	graph.data[idx] = weight

	if !graph.directed {
		idx_rev := _graph_adj_matrix_index(graph, to, from)
		graph.data[idx_rev] = weight
	}
}

// graph_adj_matrix_remove_edge removes an edge from the graph
graph_adj_matrix_remove_edge :: proc(graph: ^GraphAdjacencyMatrix($W), from, to: int) -> bool {
	if from < 0 || from >= graph.num_vertices || to < 0 || to >= graph.num_vertices {
		return false
	}

	idx := _graph_adj_matrix_index(graph, from, to)
	had_edge := graph.data[idx] != nil

	graph.data[idx] = nil

	if !graph.directed {
		idx_rev := _graph_adj_matrix_index(graph, to, from)
		graph.data[idx_rev] = nil
	}

	return had_edge
}

// graph_adj_matrix_has_edge checks if an edge exists
graph_adj_matrix_has_edge :: proc(graph: ^GraphAdjacencyMatrix($W), from, to: int) -> bool {
	if from < 0 || from >= graph.num_vertices || to < 0 || to >= graph.num_vertices {
		return false
	}

	idx := _graph_adj_matrix_index(graph, from, to)
	return graph.data[idx] != nil
}

// graph_adj_matrix_get_weight gets the weight of an edge
graph_adj_matrix_get_weight :: proc(graph: ^GraphAdjacencyMatrix($W), from, to: int) -> (W, bool) {
	if from < 0 || from >= graph.num_vertices || to < 0 || to >= graph.num_vertices {
		return {}, false
	}

	idx := _graph_adj_matrix_index(graph, from, to)
	if weight, ok := graph.data[idx].?; ok {
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
			idx := _graph_adj_matrix_index(graph, i, j)
			if graph.data[idx] != nil {
				count += 1
			}
		}
	}

	if !graph.directed {
		count /= 2
	}

	return count
}
