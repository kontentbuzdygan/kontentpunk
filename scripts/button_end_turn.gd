extends Button


func _process(_delta: float) -> void:
	disabled = CombatState.get_instance().is_in_progress()
