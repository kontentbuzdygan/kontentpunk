class_name CombatState
extends Node

signal action_ended(action: CombatAction)
signal game_ended

var _queue: Array[Object] = []
var _current_action: CombatAction = null
var _stopped: bool = false
var _turn_order: Array[Actor] = []
var _current_turn: int = 0

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

		check_game_over()
		action_ended.emit(_current_action)

		var enemies := _turn_order.slice(1)
		if enemies.all(func(enemy: Actor) -> bool: return not enemy.is_alive):
			game_ended.emit()
			SceneManager.goto_scene("res://levels/level_selector.tscn")

		if _current_action is CombatAction.EndTurn:
			next_turn()

	_current_action = null


func is_in_progress() -> bool:
	return not _queue.is_empty() or _current_action


func stop() -> void:
	_stopped = true


func add_actor(actor: Actor) -> void:
	_turn_order.append(actor)
	_turn_order.sort_custom(func(a: Actor) -> int: return a.turn_order)


func next_turn() -> void:
	for i in range(len(_turn_order)):
		_current_turn = (_current_turn + 1) % len(_turn_order)

		if _turn_order[_current_turn].is_alive:
			break

	if _turn_order[_current_turn].is_alive:
		# NOTE: Intentional await
		await _turn_order[_current_turn].begin_turn()


## check for game over here instead of PlayerState so that Autoload singleton
## doesn't have to depend on a local node
func check_game_over() -> void:
	if PlayerState.health.current <= 0:
		CombatState.get_instance().stop()
		await get_tree().create_timer(0.5).timeout
		SceneManager.goto_scene("res://objects/ui/game_over.tscn")
