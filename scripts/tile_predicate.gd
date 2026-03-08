@abstract
class_name TilePredicate
extends Resource

## Tests the predicate for the given tile coordinates, relative to the actor
@abstract func matches(tile: Vector2i) -> bool
