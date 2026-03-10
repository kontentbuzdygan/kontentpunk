class_name CombatState
extends Node

signal action_ended(action: CombatAction)
signal queue_emptied

var _queue: Array[Object] = []
var _current_action: CombatAction = null
var _stopped: bool = false

static var _instance: CombatState


static func get_instance() -> CombatState:
	assert(_instance != null, "CombatState not initialized")
	return _instance


func _ready() -> void:
	_instance = self


func queue_action(action: CombatAction) -> void:
	print(action.actor, " queued ", action)
	_queue.append(action)

	if _current_action == null:
		process_queue()


func process_queue() -> void:
	while not _stopped and not _queue.is_empty():
		_current_action = _queue.pop_front()
		await _current_action.actor.execute(_current_action)

		action_ended.emit(_current_action)

	_current_action = null
	queue_emptied.emit()


func is_in_progress() -> bool:
	return not _queue.is_empty() or _current_action


func stop() -> void:
	_stopped = true
