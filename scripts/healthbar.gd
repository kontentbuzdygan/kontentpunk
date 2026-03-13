@tool
class_name Healthbar
extends TextureProgressBar

@onready var parent: Enemy = get_parent()
var max_health: int = -1

func _ready() -> void:
	max_health = parent.health
	parent.health_changed.connect(update)
	update()


func update() -> void:
	self.value = parent.health * 100 / self.max_health
