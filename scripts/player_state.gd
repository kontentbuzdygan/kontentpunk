class_name PlayerState
extends Node

@export var _resources: Dictionary[PlayerResource.Type, PlayerResource] = {
	PlayerResource.Type.HEALTH: PlayerResource.new(5),
	PlayerResource.Type.MANA: PlayerResource.new(5),
	PlayerResource.Type.MONEY: PlayerResource.new(-1, 100),
}
var _items: Array[Item] = []
var _at_turn_end: bool = false

signal items_changed(items: Array[Item])

static var _instance: PlayerState


static func get_instance() -> PlayerState:
	assert(_instance != null, "PlayerState not initialized")
	return _instance


func _ready() -> void:
	_instance = self

	var combat_state := CombatState.get_instance()
	combat_state.action_ended.connect(_on_action_ended)
	combat_state.queue_emptied.connect(_on_queue_emptied)


func get_resource(type: PlayerResource.Type) -> PlayerResource:
	return _resources[type]


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


func _on_queue_emptied() -> void:
	if _resources[PlayerResource.Type.HEALTH].current <= 0:
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://objects/ui/game_over.tscn")
	elif _at_turn_end:
		_at_turn_end = false
		_resources[PlayerResource.Type.MANA].refill()
