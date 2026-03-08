class_name Player
extends Actor

const MANA_COST_NOT_ALLOWED: int = -1

@export var end_turn_delay_seconds: float = 0.5
@export var abilities_button_group: ButtonGroup

@onready var mana: PlayerResource = PlayerState.get_resource(PlayerResource.Type.MANA)


func _ready() -> void:
	super._ready()
	grid.tile_clicked.connect(_on_tile_clicked)
	grid.tile_hovered.connect(_on_tile_hovered)


func _on_tile_clicked(tile: Vector2i) -> void:
	var ability := get_selected_ability()

	if ability:
		if mana.current >= ability.base_mana_cost:
			grid.hide_mana_cost()
			mana.current -= ability.base_mana_cost
			print("perform %s on %s" % [ability, tile])
			clear_selected_ability()
	else:
		var current_tile := get_current_tile()

		if Utils.is_valid_axis_aligned_move(current_tile, tile):
			var distance := Utils.manhattan_distance(current_tile, tile)

			if mana.current >= distance and move_to(tile):
				grid.hide_mana_cost()
				mana.current -= distance


func _on_tile_hovered(tile: Vector2i) -> void:
	var ability := get_selected_ability()

	if ability:
		grid.show_mana_cost(ability.base_mana_cost)
	else:
		var current_tile := get_current_tile()

		if Utils.is_valid_axis_aligned_move(current_tile, tile):
			grid.show_mana_cost(Utils.manhattan_distance(current_tile, tile))


func _on_button_end_turn_pressed() -> void:
	clear_selected_ability()
	CombatState.queue_action(CombatAction.EndTurn.new(self))


func execute(action: CombatAction, then: Callable) -> void:
	if action is CombatAction.EndTurn:
		get_tree().create_timer(end_turn_delay_seconds).timeout.connect(then)
		return

	super.execute(action, then)


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
