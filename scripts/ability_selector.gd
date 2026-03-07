@tool
class_name AbilitySelector
extends Button

@export var ability: Ability:
	get:
		return _ability
	set(value):
		_ability = value
		icon = value.icon

var _ability: Ability
