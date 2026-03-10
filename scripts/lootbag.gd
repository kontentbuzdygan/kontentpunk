class_name Lootbag
extends Node2D

@export var loot: Array[Item] = []

@onready var grid: Grid = find_parent("Grid")
@onready var player: Player = get_parent().get_node("Player")
@onready var loot_container: LootContainer = %LootContainer

func _ready() -> void:
	if not loot_container:
		push_error("LootContainer missing from Lootbag")
	player.moved_to.connect(on_moved_to)


func on_moved_to(tile: Vector2i):
	if _get_current_tile() == tile:
		print("Player standing on lootbag")
		loot_container.current_lootbag = self
	elif loot_container.current_lootbag == self:
		loot_container.current_lootbag = null


func _get_current_tile():
	return grid.get_node_tile(self)


func add_loot(item_holder: ItemHolder):
	var item: Item = item_holder.item
	self.loot.append(item)
	item_holder.item = null
