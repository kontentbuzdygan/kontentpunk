class_name OrthoTilePredicate
extends TilePredicate
## Matches distances in straight lines along either of the XY axes

enum TargetTile { ANY, EMPTY, ACTOR }

@export var min_distance: int = 1
@export var max_distance: int = -1
## If `false`, the grid will be scanned for obstacles in a straight line between
## the start and target positions
@export var ignore_obstacles: bool = false
@export var target_tile: TargetTile = TargetTile.ANY


func matches(from: Vector2i, to: Vector2i, grid: Grid) -> bool:
	var dist := Utils.ortho_length(to - from)

	if dist == -1 or dist < min_distance or max_distance != -1 and dist > max_distance:
		return false

	if not ignore_obstacles:
		for test_tile in Utils.walk_ortho_tiles(from, to):
			if grid.is_tile_occupied(test_tile):
				return false

	match target_tile:
		TargetTile.EMPTY:
			if grid.is_tile_occupied(to):
				return false
		TargetTile.ACTOR:
			if not grid.get_node_on_tile(to, Actor):
				return false

	return true


func get_closest_match(
	from: Vector2i, to: Vector2i, _grid: Grid, override_max_distance: int = -1
) -> Vector2i:
	var dist := Utils.ortho_length(to - from)
	var max_dist := max_distance if override_max_distance == -1 else override_max_distance

	if max_dist == -1:
		dist = max(dist, min_distance)
	else:
		dist = clamp(dist, min_distance, max_dist)

	return from + (to - from).sign() * dist
