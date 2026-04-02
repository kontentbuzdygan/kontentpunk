class_name Player
extends Actor

const MANA_COST_NOT_ALLOWED: int = -1

@export var end_turn_delay_seconds: float = 0.5
@export var abilities_button_group: ButtonGroup
@export var loot_container: LootContainer

@onready var health: PlayerResource = PlayerState.get_instance().health
@onready var mana: PlayerResource = PlayerState.get_instance().mana


func _ready() -> void:
	super._ready()
	grid.tile_clicked.connect(_on_tile_clicked)
	grid.tile_hovered.connect(_on_tile_hovered)

	left_tile.connect(_on_left_tile)
	entered_tile.connect(_on_entered_tile)

	var player_state := PlayerState.get_instance()
	player_state.turn_begin.connect(_on_turn_begin)
	player_state.items_changed.connect(_on_items_changed)


func _on_tile_clicked(tile: Vector2i) -> void:
	var relative_tile := tile - get_current_tile()
	var ability := get_selected_ability()

	if ability.is_valid_tile(relative_tile):
		var mana_cost := ability.get_mana_cost(relative_tile)

		if mana.current >= mana_cost:
			grid.hide_mana_cost()
			mana.current -= mana_cost
			ability.perform(self, tile)
			clear_selected_ability()


func _on_tile_hovered(tile: Vector2i) -> void:
	var relative_tile := tile - get_current_tile()
	var ability := get_selected_ability()

	if ability.is_valid_tile(relative_tile):
		grid.show_mana_cost(ability.get_mana_cost(relative_tile))


func _on_button_end_turn_pressed() -> void:
	clear_selected_ability()
	CombatState.get_instance().queue_action(CombatAction.EndTurn.new(self))


func _on_left_tile(_tile: Vector2i) -> void:
	loot_container.current_lootbag = null


func _on_entered_tile(tile: Vector2i) -> void:
	for lootbag in grid.get_nodes_on_tile(tile, Lootbag):
		loot_container.current_lootbag = lootbag
		break


func execute(action: CombatAction) -> void:
	if action is CombatAction.EndTurn:
		await get_tree().create_timer(end_turn_delay_seconds).timeout
		return

	if action is CombatAction.HealSelf:
		health.current += action.value
		return

	await super.execute(action)


func take_damage(value: int) -> void:
	health.current -= value
	await super.take_damage(value)


func get_selected_ability() -> Ability:
	var button := abilities_button_group.get_pressed_button()

	if button and button.owner is AbilitySelector:
		return button.owner.ability
	else:
		return PlayerState.get_instance().default_move_ability


func clear_selected_ability() -> void:
	var button := abilities_button_group.get_pressed_button()

	if button:
		button.set_pressed_no_signal(false)


func _on_turn_begin() -> void:
	_process_status_effects()

	var player_state := PlayerState.get_instance()
	for item in player_state.get_items():
		if item.penalties.is_empty():
			continue

		if player_state.money.current < item.money_cost:
			_apply_penalties(item.penalties)
			item.is_penalty_activated = true
		else:
			item.is_penalty_activated = false
	status_bar.update()


func _apply_penalties(penalties: Array[StatusEffect]) -> void:
	for penalty in penalties:
		penalty.queue(self)


func _on_items_changed(_items: Array[Item]) -> void:
	status_bar.update()
