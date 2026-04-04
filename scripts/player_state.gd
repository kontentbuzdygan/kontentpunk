class_name PlayerState
extends Node

@export var health: PlayerResource
@export var mana: PlayerResource
@export var money: PlayerResource
@export var default_move_ability: Ability

var _items: Array[ItemSlot] = []

signal items_changed(items: Array[ItemSlot])

static var _instance: PlayerState


static func get_instance() -> PlayerState:
	assert(_instance != null, "PlayerState not initialized")
	return _instance


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_instance = self

	var combat_state := CombatState.get_instance()
	combat_state.action_ended.connect(_on_action_ended)


func get_resource(type: PlayerResource.Type) -> PlayerResource:
	match type:
		PlayerResource.Type.HEALTH:
			return health
		PlayerResource.Type.MANA:
			return mana
		PlayerResource.Type.MONEY:
			return money

	assert(false, "missing player resource type")
	return null


func get_item_slots() -> Array[ItemSlot]:
	return _items.duplicate()


func add_item(item: Item, item_holder: ItemHolder) -> void:
	print("equipped ", item)
	var item_slot := ItemSlot.new(item, item_holder)
	_items.append(item_slot)
	items_changed.emit(_items)


func remove_item(item: Item, item_holder: ItemHolder) -> void:
	print("unequipped ", item)
	_items.assign(_items.filter(func (slot: ItemSlot) -> bool: return slot.item != item or slot.item_holder != item_holder))
	items_changed.emit(_items)


func _on_action_ended(_action: CombatAction) -> void:
	if health.current <= 0:
		CombatState.get_instance().stop()
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://objects/ui/game_over.tscn")


func begin_turn() -> void:
	for item_slot in _items:
		money.current -= item_slot.item.money_cost

	mana.refill()
