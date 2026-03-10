class_name PlayerState
extends Node

@export var health: PlayerResource
@export var mana: PlayerResource
@export var money: PlayerResource

var _items: Array[Item] = []
var _at_turn_end: bool = false

signal items_changed(items: Array[Item])

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
	combat_state.queue_emptied.connect(_on_queue_emptied)


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


func add_item(item: Item) -> void:
	print("equipped ", item)
	_items.append(item)
	items_changed.emit(_items)


func remove_item(item: Item) -> void:
	print("unequipped ", item)
	_items.erase(item)
	items_changed.emit(_items)


func _on_action_ended(action: CombatAction) -> void:
	if action is CombatAction.EndTurn:
		_at_turn_end = true

	if health.current <= 0:
		CombatState.get_instance().stop()
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://objects/ui/game_over.tscn")


func _on_queue_emptied() -> void:
	if _at_turn_end:
		_at_turn_end = false
		mana.refill()
