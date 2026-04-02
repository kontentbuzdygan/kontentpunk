class_name OrthoTilePredicate
extends TilePredicate
## Matches distances in straight lines along either of the XY axes

enum TargetTile { ANY, EMPTY, ENEMY }

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
		TargetTile.ENEMY:
			if not grid.get_node_on_tile(to, Enemy):
				return false

	return true
