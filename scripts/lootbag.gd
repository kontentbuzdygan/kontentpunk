class_name Lootbag
extends Node2D

@export var loot: Array[Item] = []
@export var lootbag_capacity: int = 6

@onready var grid: Grid = find_parent("Grid")


func add_loot(item_holder: ItemHolder) -> void:
	if self.loot.size() >= lootbag_capacity:
		return

	var item: Item = item_holder.item
	self.loot.append(item)
	item_holder.item = null
