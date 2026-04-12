extends HBoxContainer

@export var ability_selector_scene: PackedScene


func _ready() -> void:
	_update_abilites()
	PlayerState.items_changed.connect(_update_abilites.unbind(1))
	PlayerState.money.current_changed.connect(_update_abilites.unbind(1))


func _update_abilites() -> void:
	clear_abilities()

	var money := PlayerState.money.current
	var abilities: Array[Ability] = []

	for item in PlayerState.get_items():
		if money >= item.money_cost:
			for ability in item.abilities:
				if not abilities.has(ability):
					abilities.append(ability)

	for i in range(len(abilities)):
		add_ability(abilities[i], i)


func clear_abilities() -> void:
	for child in find_children("", "AbilitySelector", false, false):
		child.queue_free()


func add_ability(ability: Ability, index: int) -> void:
	var selector: AbilitySelector = ability_selector_scene.instantiate()
	selector.ability = ability
	selector.set_index(index)
	add_child(selector)
