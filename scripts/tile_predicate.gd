@abstract
class_name TilePredicate
extends Resource

@abstract func matches(from: Vector2i, to: Vector2i, grid: Grid) -> bool

## Tries to find the closest tile to `to` which still matches the predicate.
## It's still necessary to call `matches` to check whether the returned tile is
## valid.
func get_closest_match(_from: Vector2i, to: Vector2i, _grid: Grid, _override_max_distance: int = -1) -> Vector2i:
	return to
