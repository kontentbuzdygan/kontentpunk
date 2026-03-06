extends Node

signal combat_action_ended(action: CombatAction)

var _combat_queue: Array[Object] = []
var _current_combat_action: CombatAction = null


func queue_combat_action(action: CombatAction) -> void:
	_combat_queue.append(action)

	if _current_combat_action == null:
		next_combat_action()


func next_combat_action() -> void:
	if not _combat_queue.is_empty():
		_current_combat_action = _combat_queue.pop_front()
		_current_combat_action.actor.execute(_current_combat_action, _end_combat_action)


func is_combat_in_progress() -> bool:
	return not _combat_queue.is_empty() or _current_combat_action


func _end_combat_action() -> void:
	combat_action_ended.emit(_current_combat_action)
	_current_combat_action = null
	next_combat_action()
