class_name SameTilePredicate
extends TilePredicate
## Matches only the current tile


func matches(tile: Vector2i) -> bool:
	return tile == Vector2i.ZERO
