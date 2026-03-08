class_name AxisAlignedTilePredicate
extends TilePredicate
## Matches distances along either of the XY axes

@export var min_distance: int = 1
@export var max_distance: int = -1


func matches(tile: Vector2i) -> bool:
	if tile.x == 0:
		return abs(tile.y) >= min_distance and (abs(tile.y) <= max_distance or max_distance == -1)
	elif tile.y == 0:
		return abs(tile.x) >= min_distance and (abs(tile.x) <= max_distance or max_distance == -1)
	else:
		return false
