class_name ActorResource
extends Resource

enum Type { HEALTH, MANA, MONEY }

@export var current: int = 5:
	set = _set_current

signal current_changed(value: int)


func _set_current(value: int) -> void:
	current = max(value, 0)
	current_changed.emit(current)


func add(value: int) -> void:
	current += max(value, 0)
	current_changed.emit(current)
