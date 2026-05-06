extends Button


func _process(_delta: float) -> void:
	disabled = not CombatState.is_waiting_for_player_input
