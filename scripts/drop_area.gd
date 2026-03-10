class_name DropArea
extends Panel

@export var grid: Grid
@export var lootbag_scene: PackedScene
@onready var loot_container: LootContainer = %LootContainer

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var player_tile = grid.find_tile_with(Player)
	var lootbag: Lootbag = grid.get_nodes_on_tile(player_tile, Lootbag).get(0)
	if not lootbag:
		lootbag = lootbag_scene.instantiate()
		grid.add_child_on_tile(lootbag, player_tile)
		lootbag.loot_container = loot_container

	lootbag.add_loot(data as ItemHolder)
	loot_container.current_lootbag = lootbag
