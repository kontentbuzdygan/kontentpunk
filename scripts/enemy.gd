extends Actor


func _ready() -> void:
	super._ready()
	CombatState.action_ended.connect(_on_combat_action_ended)


func _on_combat_action_ended(action: CombatAction) -> void:
	if action is CombatAction.EndTurn:
		move_to(grid.get_random_tile())
