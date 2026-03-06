extends Actor


func _ready() -> void:
	State.combat_action_ended.connect(_on_combat_action_ended)


func _on_combat_action_ended(action: CombatAction) -> void:
	if action.actor is Player:
		move_to(Vector2i(
			randi_range(0, grid.dimensions.x - 1),
			randi_range(0, grid.dimensions.y - 1)
		))
