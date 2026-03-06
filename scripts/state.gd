extends Node

var _input_locks: Array[Object] = []


## Registers the given object as locking user input.
## Input will be unlocked once `unlock_input` is called with the same object.
func lock_input(lock: Object) -> void:
	_input_locks.append(lock)


func unlock_input(lock: Object) -> void:
	_input_locks.erase(lock)


func is_input_locked() -> bool:
	return not _input_locks.is_empty()
