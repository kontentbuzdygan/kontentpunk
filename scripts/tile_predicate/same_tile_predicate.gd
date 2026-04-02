class_name SameTilePredicate
extends TilePredicate
## Matches only the current tile


func matches(from: Vector2i, to: Vector2i, _grid: Grid) -> bool:
	return from == to
