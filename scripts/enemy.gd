class_name Enemy
extends Actor

@export var attack_sound: AudioStream
@export var health: int = 8
@export var lootbag_scene: PackedScene
@export var drops: Array[Item]
@export var money_drop: int = 10
@export var money_drop_label_scene: PackedScene

@onready var loot_container: LootContainer = %LootContainer
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()
	CombatState.get_instance().action_ended.connect(_on_combat_action_ended)


func _on_combat_action_ended(action: CombatAction) -> void:
	if action is CombatAction.EndTurn:
		_process_status_effects()

		var player_tile := grid.find_tile_with(Player)
		var path_toward_player := grid.pathfinder.find_path(get_current_tile(), player_tile, grid, 5)

		for tile in path_toward_player:
			move_to(tile)

		if Utils.manhattan_length(player_tile - path_toward_player.back()) <= 1:
			CombatState.get_instance().queue_action(CombatAction.DealDamage.new(self, player_tile, randi() % 2 + 1))


func execute(action: CombatAction) -> void:
	if action is CombatAction.DealDamage:
		play_sound(attack_sound)

	await super.execute(action)


func take_damage(value: int) -> void:
	health = max(health - value, 0)
	await super.take_damage(value)

	if health <= 0:
		drop_loot()
		await drop_money()
		queue_free()


func drop_loot() -> void:
	if drops.size() == 0:
		return

	var enemy_tile := get_current_tile()
	var lootbag: Lootbag = grid.get_node_on_tile(enemy_tile, Lootbag)
	if not lootbag:
		lootbag = lootbag_scene.instantiate()
		grid.add_child_on_tile(lootbag, enemy_tile)

	var rng := RandomNumberGenerator.new()
	var drop_chances: Array[float] = []
	drop_chances.assign(drops.map(func (item: Item) -> float: return item.drop_chance))
	lootbag.loot.append(drops[rng.rand_weighted(drop_chances)])


func drop_money() -> void:
	sprite.visible = false

	PlayerState.get_instance().money.add(money_drop)

	var money_drop_label: MoneyDropLabel = money_drop_label_scene.instantiate()
	add_child(money_drop_label)

	await money_drop_label.play_animation(money_drop)

	remove_child(money_drop_label)
	money_drop_label.queue_free()
