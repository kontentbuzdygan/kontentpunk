@tool
class_name Item
extends Node2D

@export var _item_resource: ItemResource:
	get():
		return _item_resource
	set(value):
		if _item_resource == value:
			return

		_item_resource = value
		update_children()


func update_children() -> void:
	if _item_resource:
		$Sprite2D.texture = _item_resource.icon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
