class_name Lootbag
extends Node2D

@export var loot: Array[Item] = []

@onready var grid: Grid = find_parent("Grid")


func add_loot(item_holder: ItemHolder) -> void:
	# Restrict lootbag to only 6 items at once
	if self.loot.size() >= 6:
		return

	var item: Item = item_holder.item
	self.loot.append(item)
	item_holder.item = null
