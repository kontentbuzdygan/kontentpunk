@tool
class_name Ability
extends Resource

@export var name: String:
	get:
		return name
	set(value):
		name = value
		emit_changed()

@export var icon: Texture2D:
	get:
		return icon
	set(value):
		icon = value
		emit_changed()

@export var base_mana_cost: int:
	get:
		return base_mana_cost
	set(value):
		base_mana_cost = value
		emit_changed()

## Matches all tiles if empty
@export var valid_tiles: TilePredicate
@export var effects: Array[AbilityEffect] = []


## Tests if the ability can be performed on the given tile coordinates, relative
## to the actor
func is_valid_tile(tile: Vector2i) -> bool:
	return not valid_tiles or valid_tiles.matches(tile)


func perform(actor: Actor, target_tile: Vector2i) -> void:
	for effect in effects:
		effect.queue(actor, target_tile)


func _get_custom_preview_texture() -> Texture2D:
	return icon
