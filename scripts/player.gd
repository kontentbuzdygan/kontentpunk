class_name Player
extends Actor

const MANA_COST_NOT_ALLOWED: int = -1

@export var end_turn_delay_seconds: float = 0.5
@export var abilities_button_group: ButtonGroup

@onready var health: PlayerResource = PlayerState.get_resource(PlayerResource.Type.HEALTH)
@onready var mana: PlayerResource = PlayerState.get_resource(PlayerResource.Type.MANA)

var _move_predicate: TilePredicate


func _ready() -> void:
	super._ready()
	grid.tile_clicked.connect(_on_tile_clicked)
	grid.tile_hovered.connect(_on_tile_hovered)

	_move_predicate = AxisAlignedTilePredicate.new()


func _on_tile_clicked(tile: Vector2i) -> void:
	var relative_tile := tile - get_current_tile()
	var ability := get_selected_ability()

	if ability:
		if ability.is_valid_tile(relative_tile):
			if mana.current >= ability.base_mana_cost:
				grid.hide_mana_cost()
				mana.current -= ability.base_mana_cost
				ability.perform(self, tile)
				clear_selected_ability()
	else:
		if _move_predicate.matches(relative_tile):
			var distance := Utils.manhattan_length(relative_tile)

			if mana.current >= distance and move_to(tile):
				grid.hide_mana_cost()
				mana.current -= distance


func _on_tile_hovered(tile: Vector2i) -> void:
	var relative_tile := tile - get_current_tile()
	var ability := get_selected_ability()

	if ability:
		if ability.is_valid_tile(relative_tile):
			grid.show_mana_cost(ability.base_mana_cost)
	else:
		if _move_predicate.matches(relative_tile):
			grid.show_mana_cost(Utils.manhattan_length(relative_tile))


func _on_button_end_turn_pressed() -> void:
	clear_selected_ability()
	CombatState.queue_action(CombatAction.EndTurn.new(self))


func execute(action: CombatAction, then: Callable) -> void:
	if action is CombatAction.EndTurn:
		get_tree().create_timer(end_turn_delay_seconds).timeout.connect(then)
		return

	super.execute(action, then)


func take_damage(value: int, then: Callable) -> void:
	super.take_damage(
		value,
		func():
			health.current -= value
			grid_animation_player.play_and_then(&"hurt", then)
	)


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
