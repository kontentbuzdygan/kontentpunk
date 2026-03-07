extends Actor


func _ready() -> void:
	CombatState.action_ended.connect(_on_combat_action_ended)


func _on_combat_action_ended(action: CombatAction) -> void:
	if action.actor is Player:
		move_to(grid.get_random_tile())
