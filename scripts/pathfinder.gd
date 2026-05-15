class_name Pathfinder
extends TileMapLayer

var _astar := AStarGrid2D.new()


func _init() -> void:
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	# Manhattan generally produces straighter paths with less zig-zags
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN


func find_path(from: Vector2i, to: Vector2i, grid: Grid) -> Array[Vector2i]:
	clear()

	_astar.region = grid.get_used_rect()
	_astar.update()
	_astar.fill_solid_region(_astar.region, false)

	for tile in grid.get_occupied_tiles():
		if tile != from:
			_astar.set_point_solid(tile)

	# Note: When allow_partial_path is true and to_id is solid the search may take an unusually long time to finish.
	# https://docs.godotengine.org/en/stable/classes/class_astargrid2d.html#class-astargrid2d-method-get-id-path
	var path := _astar.get_id_path(from, to, true)

	if OS.is_debug_build():
		for tile in path:
			set_cell(tile, 1, Vector2i.ZERO)

	path = normalize_path(path)

	if OS.is_debug_build():
		for tile in path:
			set_cell(tile, 0, Vector2i.ZERO)

	return path


## Removes "collinear" jumps from the path and constraints it to the given length
func normalize_path(path: Array[Vector2i]) -> Array[Vector2i]:
	if len(path) < 2:
		return path.duplicate()

	var new_path: Array[Vector2i] = []
	var last_direction := (path[1] - path[0]).sign()

	for i in range(1, len(path)):
		var next_tile := path[i + 1] if i < len(path) - 1 else path[i]
		var direction := (next_tile - path[i]).sign()

		if direction != last_direction:
			new_path.append(path[i])

		last_direction = direction

	return new_path
