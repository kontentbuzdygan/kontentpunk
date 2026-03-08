class_name PlayerResource
extends Resource

enum Type { HEALTH, MANA }

@export var current: int = 5:
	get:
		return _current
	set(value):
		_current = clamp(value, 0, _maximum)
		current_changed.emit(_current)

@export var maximum: int = 5:
	get:
		return _maximum
	set(value):
		_maximum = max(0, value)
		maximum_changed.emit(_maximum)

		if _maximum < _current:
			current = _maximum

signal current_changed(value: int)
signal maximum_changed(value: int)

var _current: int = 5
var _maximum: int = 5


func _init(maximum_: int) -> void:
	_maximum = maximum_
	_current = maximum_
