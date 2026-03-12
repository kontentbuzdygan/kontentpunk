class_name Lootbag
extends Node2D

@export var loot: Array[Item] = []

@onready var grid: Grid = find_parent("Grid")


func add_loot(item_holder: ItemHolder) -> void:
	var item: Item = item_holder.item
	self.loot.append(item)
	item_holder.item = null
