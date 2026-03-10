class_name Lootbag
extends Node2D

@export var loot: Array[Item] = []

@onready var grid: Grid = find_parent("Grid")
@onready var player: Player = get_parent().get_node("Player")
@onready var loot_container: LootContainer = %LootContainer

func _ready() -> void:
	if not loot_container:
		push_error("LootContainer missing from Lootbag")


func _get_current_tile():
	return grid.get_node_tile(self)


func _get_player_tile():
	return grid.get_node_tile(player)


func _on_area_2d_body_entered(_body: Node2D) -> void:
	print("Player standing on lootbag")
	loot_container.current_lootbag = self


func _on_area_2d_body_exited(_body: Node2D) -> void:
	print("Player leaving lootbag")
	loot_container.clear_ui()
