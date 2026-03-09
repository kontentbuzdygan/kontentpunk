@tool
class_name Item
extends CenterContainer

@export var _item_resource: ItemResource:
	get():
		return _item_resource
	set(value):
		if _item_resource == value:
			return

		if _item_resource and _item_resource.changed.is_connected(update_children):
			_item_resource.changed.disconnect(update_children)

		_item_resource = value

		if _item_resource:
			_item_resource.changed.connect(update_children)
		update_children()


func update_children() -> void:
	if not is_node_ready():
		await ready	

	if _item_resource:
		$TextureRect.texture = _item_resource.icon
	else:
		$TextureRect.texture = null


func _get_drag_data(_at_position: Vector2) -> Item:
	var icon = TextureRect.new()
	icon.texture = _item_resource.icon
	set_drag_preview(icon)
	return self


func get_item_resource() -> ItemResource:
	return _item_resource
