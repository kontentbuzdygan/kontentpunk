extends Node

var is_running: bool:
	get:
		return _is_running

var _turn_order: Array[Actor] = []
var _current_turn: int = 0
var is_waiting_for_player_input: bool = true
var _is_running: bool = false

func reset() -> void:
	_turn_order = []
	_current_turn = 0
	is_waiting_for_player_input = true
	_is_running = false


func add_actor(actor: Actor) -> void:
	_turn_order.append(actor)
	_turn_order.sort_custom(func(a: Actor, b: Actor) -> int: return a.turn_order < b.turn_order)


func run() -> void:
	_is_running = true
	while _is_running:
		for i in range(len(_turn_order)):
			_current_turn = (_current_turn + 1) % len(_turn_order)

			if is_instance_valid(_turn_order[_current_turn]) and _turn_order[_current_turn].is_alive:
				break

		if is_instance_valid(_turn_order[_current_turn]) and _turn_order[_current_turn].is_alive:
			@warning_ignore("redundant_await")
			await _turn_order[_current_turn].perform_turn()


func stop() -> void:
	_is_running = false
