extends HBoxContainer

@export var ability_selector_scene: PackedScene


func _ready() -> void:
	clear_abilities()
	PlayerState.items_changed.connect(_on_items_changed)


func _on_items_changed(items: Array[Item]) -> void:
	clear_abilities()

	var abilities: Array[Ability] = []

	for item in items:
		for ability in item.abilities:
			if not abilities.has(ability):
				abilities.append(ability)

	for ability in abilities:
		add_ability(ability)


func clear_abilities() -> void:
	for child in find_children("", "AbilitySelector", false, false):
		child.queue_free()


func add_ability(ability: Ability) -> void:
	var selector: AbilitySelector = ability_selector_scene.instantiate()
	selector.ability = ability
	add_child(selector)
