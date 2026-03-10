extends Node2D

@onready var grid: Grid = find_parent("Grid")
@onready var player: Player = get_parent().get_node("Player")

signal _lootbag_state_changed(open: bool, loot: Array[Item])

var _loot: Array[Item] = []
var _is_lootbag_opened = false


func _ready() -> void:
	CombatState.get_instance().action_ended.connect(_on_action_ended)


func _on_action_ended(_action: CombatAction):
	if _get_player_tile() == _get_current_tile() and not _is_lootbag_opened:
		_is_lootbag_opened = true
		_lootbag_state_changed.emit(true, _loot)
	else:
		_is_lootbag_opened = false
		_lootbag_state_changed.emit(false, [])


func _get_current_tile():
	return grid.get_node_tile(self)


func _get_player_tile():
	return grid.get_node_tile(player)
