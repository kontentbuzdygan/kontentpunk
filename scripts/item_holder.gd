@tool
class_name ItemHolder
extends CenterContainer

@export var item_type: ItemResource.ITEM_TYPE
@export var _item_resource: ItemResource:
	get():
		return _item_resource
	set(value):
		print(value)
		if _item_resource == value:
			return

		if _item_resource and _item_resource.changed.is_connected(update_children):
			_item_resource.changed.disconnect(update_children)

		_item_resource = value

		if _item_resource:
			_item_resource.changed.connect(update_children)
		update_children()

var tooltip_scene = preload("res://objects/ui/item_tooltip.tscn")
signal item_equipped(item: ItemResource)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var item_holder = data as ItemHolder

	if _item_resource:
		return item_holder._item_resource.item_type == _item_resource.item_type
	else:
		return item_holder._item_resource.item_type == item_type or item_type == ItemResource.ITEM_TYPE.NONE 


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var item_holder = data as ItemHolder
	var temp = _item_resource
	_item_resource = item_holder._item_resource
	item_holder._item_resource = temp
	update_children()


func update_children():
	if not Engine.is_editor_hint() and not is_node_ready():
		await ready

	if _item_resource:
		$ItemSlot.texture = _item_resource.icon
		item_equipped.emit(_item_resource)
	else:
		$ItemSlot.texture = null


func _get_drag_data(_at_position: Vector2) -> ItemHolder:
	if not _item_resource:
		return

	var icon = TextureRect.new()
	icon.texture = _item_resource.icon
	set_drag_preview(icon)
	return self


func _make_custom_tooltip(for_text: String) -> Object:
	if not _item_resource:
		return null

	var tooltip: ItemTooltip = tooltip_scene.instantiate()
	tooltip.text = for_text
	return tooltip


func _get_tooltip(_at_position: Vector2) -> String:
	if not _item_resource:
		return "Missing item"
	return _item_resource.name
