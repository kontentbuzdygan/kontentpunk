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

			if item.changed.is_connected(update_children):
				item.changed.disconnect(update_children)

		item = value

		if item:
			if type == Type.EQUIPMENT:
				PlayerState.add_item(item)

			item.changed.connect(update_children)

		if not Engine.is_editor_hint() and not item and type == Type.TEMPORARY:
			queue_free()
			return

		update_children()

@export var tooltip_scene: PackedScene


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
		return source.item.item_type == item.item_type
	else:
		return source.item.item_type == item_type or item_type == Item.Type.NONE


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


func _make_custom_tooltip(for_text: String) -> Object:
	if not item:
		return null

	var tooltip: ItemTooltip = tooltip_scene.instantiate()
	tooltip.text = for_text
	return tooltip


func _get_tooltip(_at_position: Vector2) -> String:
	if not item:
		return "Missing item"
	return item.name
