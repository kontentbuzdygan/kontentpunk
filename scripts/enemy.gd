class_name Enemy
extends Actor

@export var death_sound: AudioStream
@export var max_health: int = 8
@export var lootbag_scene: PackedScene
@export var money_drop: int = 10
@export var money_drop_label_scene: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var inventory: Inventory = $Inventory
@onready var health: int = max_health


func perform_turn() -> void:
	_process_status_effects()

	var player_tile := grid.find_tile_with(Player)
	var path_toward_player := grid.pathfinder.find_path(get_current_tile(), player_tile, grid, 3)

	for tile in path_toward_player:
		await move_to(tile)

	# TODO: Replace with actual ability checks & effects
	if Utils.manhattan_length(player_tile - path_toward_player.back()) <= 1:
		var player: Player = grid.get_node_on_tile(player_tile, Player)
		await player.take_damage(randi() % 2 + 1)


func take_damage(value: int) -> void:
	health = max(health - value, 0)
	await super.take_damage(value)

	if health <= 0:
		await get_tree().create_timer(0.5).timeout
		play_sound(death_sound)
		drop_loot()
		await drop_money()
		is_alive = false
		remove_from_group(&"occupies_tile")


func heal(value: int) -> void:
	health = min(health + value, max_health)


func drop_loot() -> void:
	if inventory.items.is_empty():
		return

	var enemy_tile := get_current_tile()
	var lootbag: Lootbag = grid.get_node_on_tile(enemy_tile, Lootbag)
	if not lootbag:
		lootbag = lootbag_scene.instantiate()
		grid.add_child_on_tile(lootbag, enemy_tile)

	var loot := inventory.get_random_loot()
	print(self, " dropped ", loot)
	lootbag.loot.append_array(loot)


func drop_money() -> void:
	sprite.visible = false

	PlayerState.get_instance().money.add(money_drop)

	var money_drop_label: MoneyDropLabel = money_drop_label_scene.instantiate()
	add_child(money_drop_label)

	await money_drop_label.play_animation(money_drop)

	remove_child(money_drop_label)
	money_drop_label.queue_free()
