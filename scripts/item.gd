@tool
class_name Item
extends Resource

enum Type { NONE = -1, HEAD, HEART, ARM, SPINE, LEG }

@export var name: String:
	get:
		return name
	set(value):
		name = value
		changed.emit()

@export var icon: Texture2D:
	get:
		return icon
	set(value):
		icon = value
		changed.emit()

@export var item_type: Type:
	get:
		return item_type
	set(value):
		item_type = value
		changed.emit()

@export var ability: Ability:
	get:
		return ability
	set(value):
		ability = value
		changed.emit()

@export var cost_per_turn: int:
	get:
		return cost_per_turn
	set(value):
		cost_per_turn = value
		changed.emit()

@export var stamina: int:
	get:
		return stamina
	set(value):
		stamina = value
		changed.emit()

@export var cooldown: int:
	get:
		return cooldown
	set(value):
		cooldown = value
		changed.emit()

@export var tooltip: String:
	get:
		return tooltip
	set(value):
		tooltip = value
		changed.emit()


func _to_string() -> String:
	return name


func _get_custom_preview_texture() -> Texture2D:
	return icon
