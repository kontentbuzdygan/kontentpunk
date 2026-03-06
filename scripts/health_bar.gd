@tool
extends HBoxContainer

@export var health: int = 5:
	get:
		return _health
	set(value):
		_health = value
		update_hearts()

@export var max_health: int = 5:
	get:
		return _max_health
	set(value):
		_max_health = value
		regenerate_hearts()

var _health: int = 5
var _max_health: int = 5

@onready var heart: Node = $Heart


func _ready() -> void:
	regenerate_hearts()
	update_hearts()


func regenerate_hearts() -> void:
	if not heart:
		return

	for child in get_children(true).slice(_max_health):
		if child != heart:
			child.queue_free()

	for i in range(len(get_children(true)), _max_health):
		var new_heart := heart.duplicate()
		add_child(new_heart, INTERNAL_MODE_BACK)

	update_hearts()


func update_hearts() -> void:
	if not heart:
		return

	var children := get_children(true)

	for i in range(len(children)):
		var sprite := children[i].get_node(^"AnimatedSprite2D") as AnimatedSprite2D
		sprite.animation = &"empty" if i >= _health else &"full"
		sprite.frame = (_max_health - i) % sprite.sprite_frames.get_frame_count(&"full")
