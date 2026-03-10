extends Actor

@export var attack_sound: AudioStream
@export var health: int = 8


func _ready() -> void:
	super._ready()
	CombatState.get_instance().action_ended.connect(_on_combat_action_ended)


func _on_combat_action_ended(action: CombatAction) -> void:
	if action is CombatAction.EndTurn:
		move_to(grid.get_random_tile())
		var player_tile := grid.find_tile_with(Player)
		CombatState.get_instance().queue_action(CombatAction.DealDamage.new(self, player_tile, 1))


func execute(action: CombatAction) -> void:
	if action is CombatAction.DealDamage:
		play_sound(attack_sound)

	await super.execute(action)


func take_damage(value: int) -> void:
	health = max(health - value, 0)
	await super.take_damage(value)

	if health <= 0:
		queue_free()
