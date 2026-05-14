class_name Enemy
extends Actor

@export var death_sound: AudioStream
@export var health: ActorResourceLimited
@export var mana: ActorResourceLimited
@export var lootbag_scene: PackedScene
@export var money_drop: int = 10
@export var money_drop_label_scene: PackedScene
@export var default_move_ability: Ability

@onready var sprite: Sprite2D = $Sprite2D
@onready var inventory: Inventory = $Inventory

var _ability_uses: Dictionary[Ability, int]


func perform_turn() -> void:
	_process_status_effects()

	var abilities := inventory.get_active_abilities()
	var player_tile := grid.find_tile_with(Player)

	mana.refill()
	_ability_uses.clear()

	while await perform_best_ability(abilities, player_tile):
		pass


func perform_best_ability(abilities: Array[Ability], player_tile: Vector2i) -> bool:
	for ability in abilities:
		if ability.damage_value > 0 and ability.is_valid_tile(self, player_tile):
			if await try_perform_ability(ability, player_tile):
				return true

	if health.current < health.maximum:
		for ability in abilities:
			if ability.healing_value > 0:
				if await try_perform_ability(ability, get_current_tile()):
					return true

	return await try_move_toward(abilities, player_tile)


func try_perform_ability(ability: Ability, target_tile: Vector2i) -> bool:
	var uses: int = _ability_uses.get(ability, 0)
	if ability.ai_max_uses_per_turn != -1 and uses >= ability.ai_max_uses_per_turn:
		return false

	var mana_cost := ability.get_mana_cost(self, target_tile)
	if mana_cost <= mana.current:
		mana.current -= mana_cost
		await ability.perform(self, target_tile)
		_ability_uses[ability] = uses + 1
		return true
	return false


## Returns a boolean indicating whether any move occured and whether the AI loop
## should run again to check for new possibilities
func try_move_toward(_abilities: Array[Ability], target_tile: Vector2i) -> bool:
	var starting_tile := get_current_tile()

	if Utils.manhattan_length(target_tile - starting_tile) <= 1:
		return false

	var path := grid.pathfinder.find_path(starting_tile, target_tile, grid)

	if path.is_empty():
		return false

	# TODO: Use custom movement abilities

	var moved := false

	for tile in path:
		var constrained_tile := default_move_ability.get_closest_valid_tile(self, tile, mana.current)
		if constrained_tile != tile:
			print(name, " wants to move to ", tile, " but can only reach ", constrained_tile)

		if not default_move_ability.is_valid_tile(self, constrained_tile):
			break
		if not await try_perform_ability(default_move_ability, constrained_tile):
			break

		moved = true

	return moved


func take_damage(value: int) -> void:
	health.current -= value
	await super.take_damage(value)

	if health.current <= 0:
		await get_tree().create_timer(0.5).timeout
		play_sound(death_sound)
		drop_loot()
		await drop_money()
		is_alive = false
		remove_from_group(&"occupies_tile")


func heal(value: int) -> void:
	health.current += value


func drop_loot() -> void:
	if inventory.items.is_empty():
		return

	var enemy_tile := get_current_tile()
	var lootbag: Lootbag = grid.get_node_on_tile(enemy_tile, Lootbag)
	if not lootbag:
		lootbag = lootbag_scene.instantiate()
		grid.add_child_on_tile(lootbag, enemy_tile)

	var loot := inventory.get_random_loot()
	print(name, " dropped ", loot)
	lootbag.loot.append_array(loot)


func drop_money() -> void:
	sprite.visible = false

	PlayerState.get_instance().money.add(money_drop)

	var money_drop_label: MoneyDropLabel = money_drop_label_scene.instantiate()
	add_child(money_drop_label)

	await money_drop_label.play_animation(money_drop)

	remove_child(money_drop_label)
	money_drop_label.queue_free()
