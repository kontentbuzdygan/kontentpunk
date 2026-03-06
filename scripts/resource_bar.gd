@tool
extends HFlowContainer

@export var resource: PlayerResource

@onready var icon: Node = $Icon
@onready var _current: int = resource.current
@onready var _maximum: int = resource.maximum


func _ready() -> void:
	resource.current_changed.connect(_on_current_changed)
	resource.maximum_changed.connect(_on_maximum_changed)

	regenerate_icons()
	update_icons()


func _on_current_changed(value: int) -> void:
	_current = value
	update_icons()


func _on_maximum_changed(value: int) -> void:
	_maximum = value
	regenerate_icons()


func regenerate_icons() -> void:
	if not icon:
		return

	for child in get_children(true).slice(_maximum):
		if child != icon:
			child.queue_free()

	for i in range(len(get_children(true)), _maximum):
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
		sprite.frame = (_maximum - i) % sprite.sprite_frames.get_frame_count(&"full")
