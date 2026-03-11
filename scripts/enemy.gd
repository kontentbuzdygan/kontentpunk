extends Actor

@export var attack_sound: AudioStream
@export var health: int = 8
@export var lootbag_scene: PackedScene
@export var drops: Array[Item]
@onready var loot_container = %LootContainer

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
		drop_loot()
		queue_free()


func drop_loot():
	if drops.size() == 0:
		return

	var enemy_tile = get_current_tile()
	var lootbag: Lootbag = grid.get_nodes_on_tile(enemy_tile, Lootbag).get(0)
	if not lootbag:
		lootbag = lootbag_scene.instantiate()
		grid.add_child_on_tile(lootbag, enemy_tile)
		lootbag.loot_container = loot_container

	var rng = RandomNumberGenerator.new()
	var drop_chances: Array[float] = []
	drop_chances.assign(drops.map(func (item: Item): return item.drop_chance))
	lootbag.loot.append(drops[rng.rand_weighted(drop_chances)])
