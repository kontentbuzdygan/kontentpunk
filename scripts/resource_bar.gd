@tool
extends HFlowContainer

@export var current: int = 5:
	get:
		return _current
	set(value):
		_current = value
		update_icons()

@export var max: int = 5:
	get:
		return _max
	set(value):
		_max = value
		regenerate_icons()

var _current: int = 5
var _max: int = 5

@onready var icon: Node = $Icon


func _ready() -> void:
	regenerate_icons()
	update_icons()


func regenerate_icons() -> void:
	if not icon:
		return

	for child in get_children(true).slice(_max):
		if child != icon:
			child.queue_free()

	for i in range(len(get_children(true)), _max):
		var new_icon := icon.duplicate()
		add_child(new_icon, INTERNAL_MODE_BACK)

	update_icons()


func update_icons() -> void:
	if not icon:
		return

	var children := get_children(true)

	for i in range(len(children)):
		var sprite := children[i].get_node(^"AnimatedSprite2D") as AnimatedSprite2D
		sprite.animation = &"empty" if i >= _current else &"full"
		sprite.frame = (_max - i) % sprite.sprite_frames.get_frame_count(&"full")
