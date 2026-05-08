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
## How many times enemies can use this ability per turn, `-1` means no limit
@export var ai_max_uses_per_turn: int = -1

## Matches all tiles if empty
@export var valid_tiles: TilePredicate

@export var damage_value: int
@export var healing_value: int
@export var target_status_effect: StatusEffect
@export_range(0.0, 1.0) var target_status_effect_chance: float = 1.0
@export var move_to_target: bool


func is_valid_tile(actor: Actor, target_tile: Vector2i) -> bool:
	var from := actor.get_current_tile()
	return not valid_tiles or valid_tiles.matches(from, target_tile, actor.grid)


func get_closest_valid_tile(actor: Actor, target_tile: Vector2i, max_mana_cost: int) -> Vector2i:
	if not valid_tiles:
		return target_tile

	var from := actor.get_current_tile()
	var max_dist := (max_mana_cost - base_mana_cost) / mana_cost_per_tile
	return valid_tiles.get_closest_match(from, target_tile, actor.grid, max_dist)


func get_mana_cost(actor: Actor, target_tile: Vector2i) -> int:
	var delta := target_tile - actor.get_current_tile()
	return base_mana_cost + Utils.manhattan_length(delta) * mana_cost_per_tile


func perform(actor: Actor, target_tile: Vector2i) -> void:
	var target_actor: Actor = actor.grid.get_node_on_tile(target_tile, Actor)

	print(actor.name, " uses ", name, " on", _target_name(actor, target_actor), " ", target_tile)

	if sound_effect:
		actor.play_sound(sound_effect)

	if target_actor and damage_value > 0:
		await target_actor.take_damage(damage_value)
	if target_actor and target_status_effect and randf() <= target_status_effect_chance:
		target_actor.apply_status_effect(target_status_effect)

	if healing_value > 0:
		await actor.heal(healing_value)
	if move_to_target:
		await actor.move_to(target_tile)


func _get_custom_preview_texture() -> Texture2D:
	return icon


func _target_name(caster: Actor, target: Actor) -> String:
	if caster == target:
		return " self"
	elif target:
		return " %s" % target.name
	else:
		return ""
