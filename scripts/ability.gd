@tool
class_name Ability
extends Resource

@export var icon: Texture2D:
	get:
		return _icon
	set(value):
		_icon = value
		emit_changed()

@export var base_mana_cost: int:
	get:
		return _base_mana_cost
	set(value):
		_base_mana_cost = value
		emit_changed()

@export var valid_tiles: TilePredicate

var _icon: Texture2D
var _base_mana_cost: int


## Tests if the ability can be performed on the given tile coordinates, relative
## to the actor
func is_valid_tile(tile: Vector2i) -> bool:
	return not valid_tiles or valid_tiles.matches(tile)
