@tool
class_name ItemHolder
extends CenterContainer

enum Type { TEMPORARY, EQUIPMENT }

@export var type: Type = Type.TEMPORARY
@export var item_type: Item.Type = Item.Type.NONE
@export var item: Item:
	get:
		return item
	set(value):
		if item == value:
			return

		if item:
			if type == Type.EQUIPMENT:
				PlayerState.remove_item(item)

			if item.icon_changed.is_connected(update_children.unbind(1)):
				item.icon_changed.disconnect(update_children.unbind(1))

		item = value

		if item:
			if type == Type.EQUIPMENT:
				PlayerState.add_item(item)

			item.icon_changed.connect(update_children.unbind(1))

		if not Engine.is_editor_hint() and not item and type == Type.TEMPORARY:
			queue_free()
			return

		update_children()


func _ready() -> void:
	update_children()


func _get_drag_data(at_position: Vector2) -> ItemHolder:
	if not item:
		return

	var icon = TextureRect.new()
	icon.texture = item.icon

	var wrapper = Control.new()
	wrapper.add_child(icon)

	icon.position = -at_position

	set_drag_preview(wrapper)
	return self


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is not ItemHolder:
		return false

	var source := data as ItemHolder

	if item:
		# swapping
		return item_type == source.item.type and source.item_type == item.type
	else:
		return item_type == source.item.type or item_type == Item.Type.NONE


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is not ItemHolder:
		return

	var source := data as ItemHolder

	if source == self or type == Type.TEMPORARY and source.type == Type.TEMPORARY:
		return

	var temp = item
	item = source.item
	source.item = temp

	if item:
		$AudioStreamPlayer.play()

	update_children()


func update_children():
	if not is_node_ready():
		return

	if item:
		$ItemSlot.texture = item.icon
	else:
		$ItemSlot.texture = null


func _get_tooltip(_at_position: Vector2) -> String:
	return item.name if item else ""
