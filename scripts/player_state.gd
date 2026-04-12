extends Node

@export var health: PlayerResource
@export var mana: PlayerResource
@export var money: PlayerResource
@export var default_move_ability: Ability

var _items: Array[Item] = []

signal items_changed(items: Array[Item])


func get_resource(type: PlayerResource.Type) -> PlayerResource:
	match type:
		PlayerResource.Type.HEALTH:
			return health
		PlayerResource.Type.MANA:
			return mana
		PlayerResource.Type.MONEY:
			return money

	assert(false, "missing player resource type")
	return null


func get_items() -> Array[Item]:
	return _items.duplicate()


func add_item(item: Item) -> void:
	print("equipped ", item)
	_items.append(item)
	items_changed.emit(_items)


func remove_item(item: Item) -> void:
	print("unequipped ", item)
	_items.erase(item)
	items_changed.emit(_items)


func begin_turn() -> void:
	for item in _items:
		if money.current >= item.money_cost:
			money.current -= item.money_cost
	mana.refill()


func restart() -> void:
	_items.clear()
	health.refill()
	mana.refill()
	## TODO: better way to store starting amount?
	money.current = 100
