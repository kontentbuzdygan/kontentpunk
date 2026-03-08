extends Actor


func _ready() -> void:
	super._ready()
	CombatState.action_ended.connect(_on_combat_action_ended)


func _on_combat_action_ended(action: CombatAction) -> void:
	if action is CombatAction.EndTurn:
		move_to(grid.get_random_tile())
		var player_tile := grid.find_tile_with(Player)
		CombatState.queue_action(CombatAction.DealDamage.new(self, player_tile, 1))
