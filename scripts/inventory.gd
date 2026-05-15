class_name Inventory
extends Node

@export var initial_items: Array[Item]

var items: Array[Item]:
	get:
		return _items.duplicate()

var _items: Array[Item]

signal changed(items: Array[Item])


func _ready() -> void:
	_items.assign(initial_items)


func add(item: Item) -> void:
	print(get_parent().name, " equipped ", item)
	_items.append(item)
	changed.emit(_items)


func remove(item: Item) -> void:
	print(get_parent().name, " unequipped ", item)
	_items.erase(item)
	changed.emit(_items)


func get_active_items() -> Array[Item]:
	var parent: Node = get_parent()
	if parent is PlayerState:
		return _items.filter(func(i: Item) -> bool: return parent.money.current >= i.money_cost)
	else:
		return _items.duplicate()


func get_active_abilities() -> Array[Ability]:
	var abilities: Array[Ability]
	for item in get_active_items():
		for ability in item.abilities:
			if not abilities.has(ability):
				abilities.append(ability)
	return abilities


func get_random_loot() -> Array[Item]:
	var loot: Array[Item]
	for item in _items:
		if randf() < item.drop_chance:
			loot.append(item)
	return loot
