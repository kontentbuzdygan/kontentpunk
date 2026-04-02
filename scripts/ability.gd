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

@export var sound_effect: AudioStream

@export var base_mana_cost: int:
	get:
		return base_mana_cost
	set(value):
		base_mana_cost = value
		emit_changed()

@export var mana_cost_per_tile: int

## Matches all tiles if empty
@export var valid_tiles: TilePredicate
@export var effects: Array[AbilityEffect] = []


func is_valid_tile(actor: Actor, target_tile: Vector2i) -> bool:
	var from := actor.get_current_tile()
	return not valid_tiles or valid_tiles.matches(from, target_tile, actor.grid)


func get_mana_cost(actor: Actor, target_tile: Vector2i) -> int:
	var delta := target_tile - actor.get_current_tile()
	return base_mana_cost + Utils.manhattan_length(delta) * mana_cost_per_tile


func perform(actor: Actor, target_tile: Vector2i) -> void:
	if sound_effect:
		actor.play_sound(sound_effect)

	for effect in effects:
		effect.queue(actor, target_tile)


func _get_custom_preview_texture() -> Texture2D:
	return icon
