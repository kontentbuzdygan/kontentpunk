extends Node

signal action_ended(action: CombatAction)

var _queue: Array[Object] = []
var _current_action: CombatAction = null


func queue_action(action: CombatAction) -> void:
	print(action.actor, " queued ", action)
	_queue.append(action)

	if _current_action == null:
		next_action()


func next_action() -> void:
	if not _queue.is_empty():
		_current_action = _queue.pop_front()
		_current_action.actor.execute(_current_action, _end_current_action)


func is_in_progress() -> bool:
	return not _queue.is_empty() or _current_action


func _end_current_action() -> void:
	action_ended.emit(_current_action)
	_current_action = null
	next_action()
