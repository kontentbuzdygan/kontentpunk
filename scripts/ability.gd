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

var _icon: Texture2D
var _base_mana_cost: int
