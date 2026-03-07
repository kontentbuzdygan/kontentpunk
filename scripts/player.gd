class_name Player
extends Actor

@export var abilities_button_group: ButtonGroup
@export var mana: PlayerResource


func _on_tile_selected(tile: Vector2i) -> void:
	var ability := get_selected_ability()

	if ability:
		if mana.current >= ability.base_mana_cost:
			mana.current -= ability.base_mana_cost
			print("perform %s on %s" % [ability, tile])
			clear_selected_ability()
	else:
		var current_tile := get_current_tile()

		if current_tile.x != tile.x and current_tile.y != tile.y:
			return

		if mana.current >= 1 and move_to(tile):
			mana.current -= 1


func get_selected_ability() -> Ability:
	var button := abilities_button_group.get_pressed_button()

	if button is AbilitySelector:
		return button.ability
	else:
		return null


func clear_selected_ability() -> void:
	var button := abilities_button_group.get_pressed_button()

	if button:
		button.set_pressed_no_signal(false)
