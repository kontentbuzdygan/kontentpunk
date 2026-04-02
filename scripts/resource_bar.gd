extends HFlowContainer

@export var resource_type: PlayerResource.Type

@onready var icon: Node = $Icon
@onready var resource: PlayerResource = PlayerState.get_instance().get_resource(resource_type)


func _ready() -> void:
	resource.current_changed.connect(_on_current_changed)
	resource.maximum_changed.connect(_on_maximum_changed)

	regenerate_icons()
	update_icons()


func _on_current_changed(_value: int) -> void:
	update_icons()


func _on_maximum_changed(_value: int) -> void:
	regenerate_icons()


func regenerate_icons() -> void:
	for child: Node in get_children(true).slice(resource.maximum):
		if child != icon:
			child.queue_free()

	for i in range(len(get_children(true)), resource.maximum):
		var new_icon := icon.duplicate()
		add_child(new_icon, INTERNAL_MODE_BACK)

	update_icons()


func update_icons() -> void:
	var children := get_children(true)

	for i in range(len(children)):
		var sprite := children[i].get_node(^"AnimatedSprite2D") as AnimatedSprite2D
		sprite.animation = &"empty" if i >= resource.current else &"full"
		sprite.frame = (resource.maximum - i) % sprite.sprite_frames.get_frame_count(&"full")
