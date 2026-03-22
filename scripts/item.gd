@tool
class_name Item
extends Resource

enum Type { NONE = -1, HEAD, HEART, ARM, SPINE, LEG }

@export var name: String
@export var icon: Texture2D:
	get:
		return icon
	set(value):
		icon = value
		icon_changed.emit(icon)

@export var type: Type = Type.NONE
@export var abilities: Array[Ability] = []
@export var money_cost: int = 1
@export var drop_chance: float = 1:
	get():
		return drop_chance
	set(value):
		drop_chance = clamp(value, 0.0, 1.0)
@export var penalties: Array[StatusEffect]
var is_penalty_activated: bool = false

signal icon_changed(icon: Texture2D)


func _to_string() -> String:
	return name


func _get_custom_preview_texture() -> Texture2D:
	return icon
