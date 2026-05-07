class_name ActorResourceLimited
extends ActorResource

@export var maximum: int = 5:
	get:
		return maximum
	set(value):
		maximum = value
		maximum_changed.emit(maximum)

		if maximum != -1 and maximum < current:
			current = maximum

signal maximum_changed(value: int)


func refill() -> void:
	current = maximum


func _set_current(value: int) -> void:
	super._set_current(min(value, maximum))
