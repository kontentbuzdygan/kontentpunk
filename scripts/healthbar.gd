@tool
class_name Healthbar
extends TextureProgressBar

@onready var parent: Enemy = get_parent()

func _ready() -> void:
	parent.health_changed.connect(update)
	update()


func update() -> void:
	self.value = parent.health * 100 / parent.max_health
