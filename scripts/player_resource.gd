class_name PlayerResource
extends Resource

enum Type { HEALTH, MANA, MONEY }

@export var current: int = 5:
	get:
		return current
	set(value):
		if maximum >= 0:
			current = clamp(value, 0, maximum)
		else:
			current = max(value, 0)

		current_changed.emit(current)

@export var maximum: int = 5:
	get:
		return maximum
	set(value):
		maximum = max(0, value)
		maximum_changed.emit(maximum)

		if maximum >= 0 and maximum < current:
			current = maximum

signal current_changed(value: int)
signal maximum_changed(value: int)


func _init(maximum_: int, current_: int = maximum_) -> void:
	maximum = maximum_
	current = current_


func refill() -> void:
	current = maximum
