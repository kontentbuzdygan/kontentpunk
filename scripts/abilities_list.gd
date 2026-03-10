extends HBoxContainer

@export var ability_selector_scene: PackedScene


func _ready() -> void:
	clear_abilities()
	PlayerState.get_instance().items_changed.connect(_on_items_changed)


func _on_items_changed(items: Array[Item]) -> void:
	clear_abilities()

	var abilities: Array[Ability] = []

	for item in items:
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
