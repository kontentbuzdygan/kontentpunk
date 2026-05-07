class_name Healthbar
extends TextureProgressBar

@onready var parent: Enemy = get_parent()

func _ready() -> void:
	if parent.health:
		parent.health.current_changed.connect(update)
		update(parent.health.current)


func update(health: int) -> void:
	self.value = health * 100 / parent.health.maximum
