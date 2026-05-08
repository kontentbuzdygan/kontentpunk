@tool
class_name ItemHolder
extends Control

enum Type {TEMPORARY, EQUIPMENT}

@export var type: Type = Type.TEMPORARY
@export var item_type: Item.Type = Item.Type.NONE
@export var item: Item:
	get:
		return item
	set(value):
		if not value:
			take_item()

		if item == value:
			return

		if item:
			if item.icon_changed.is_connected(_update_children.unbind(1)):
				item.icon_changed.disconnect(_update_children.unbind(1))

			_on_item_removed(item)

		item = value

		if item:
			item.icon_changed.connect(_update_children.unbind(1))

		_on_item_changed(item)
		_update_children()

@onready var status_effect_receiver: StatusEffectReceiver = $StatusEffectReceiver


func _on_item_removed(old_item: Item) -> void:
	if Engine.is_editor_hint() or not is_node_ready():
		return

	if type == Type.EQUIPMENT:
		PlayerState.get_instance().inventory.remove(old_item)


func _on_item_changed(new_item: Item) -> void:
	if Engine.is_editor_hint() or not is_node_ready():
		return

	if new_item and type == Type.EQUIPMENT:
		PlayerState.get_instance().inventory.add(new_item)
	elif not new_item and type == Type.TEMPORARY:
		queue_free()
		return


func _ready() -> void:
	_update_children()


func _get_drag_data(at_position: Vector2) -> ItemHolder:
	if not item:
		return

	var icon := TextureRect.new()
	icon.texture = item.icon

	var wrapper := Control.new()
	wrapper.add_child(icon)

	icon.position = - at_position

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

	var temp := item
	item = source.item
	source.item = temp

	if item:
		$AudioStreamPlayer.play()

	_update_children()


func _update_children() -> void:
	if not is_node_ready():
		return

	if item:
		$ItemSlot.texture = item.icon
		$MoneyCostDisplay.cost = item.money_cost
		$MoneyCostDisplay.visible = true
	else:
		$ItemSlot.texture = null
		if not Engine.is_editor_hint():
			$MoneyCostDisplay.visible = false


func _get_tooltip(_at_position: Vector2) -> String:
	return item.name if item else ""


func take_item() -> void:
	if type == Type.TEMPORARY:
		var loot_container: LootContainer = find_parent("LootContainer")
		loot_container.on_take_item(item)


func begin_turn(player: Player) -> void:
	if item:
		var player_state := PlayerState.get_instance()
		# Don't apply penalty if player paid for the item in this turn
		if player_state.money.current >= item.money_cost:
			player_state.money.current -= item.money_cost
		elif player_state.money.current < item.money_cost:
			for penalty in item.penalties:
				status_effect_receiver.apply(player, penalty)

	status_effect_receiver.on_turn(player)
