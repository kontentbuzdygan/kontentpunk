class_name Player
extends Actor

@export var end_turn_delay_seconds: float = 0.5


class EndTurn:
	extends CombatAction

	func _to_string() -> String:
		return "<end turn>"


@export var abilities_button_group: ButtonGroup

@onready var mana: PlayerResource = PlayerState.get_resource(PlayerResource.Type.MANA)


func execute(action: CombatAction, then: Callable) -> void:
	if action is EndTurn:
		get_tree().create_timer(end_turn_delay_seconds).timeout.connect(then)
		return

	super.execute(action, then)


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

		var distance: int = abs(tile.x - current_tile.x) + abs(tile.y - current_tile.y)

		if mana.current >= distance and move_to(tile):
			mana.current -= distance


func _on_button_end_turn_pressed() -> void:
	clear_selected_ability()
	CombatState.queue_action(EndTurn.new(self))


func get_selected_ability() -> Ability:
	var button := abilities_button_group.get_pressed_button()

	if button and button.owner is AbilitySelector:
		return button.owner.ability
	else:
		return null


func clear_selected_ability() -> void:
	var button := abilities_button_group.get_pressed_button()

	if button:
		button.set_pressed_no_signal(false)
