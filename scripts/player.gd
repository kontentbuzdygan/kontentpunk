class_name Player
extends Actor

const MANA_COST_NOT_ALLOWED: int = -1

@export var end_turn_delay_seconds: float = 0.5
@export var abilities_button_group: ButtonGroup
@export var loot_container: LootContainer

@onready var health: ActorResourceLimited = PlayerState.get_instance().health
@onready var mana: ActorResource = PlayerState.get_instance().mana

var equipement_slots: Array[ItemHolder]

signal _turn_ended


func _ready() -> void:
	super._ready()

	var untyped_equipment_slots := %Equipment.find_children("", "ItemHolder")
	equipement_slots.assign(untyped_equipment_slots)

	grid.tile_clicked.connect(_on_tile_clicked)
	grid.tile_hovered.connect(_on_tile_hovered)

	left_tile.connect(_on_left_tile)
	entered_tile.connect(_on_entered_tile)

	var player_state := PlayerState.get_instance()
	player_state.inventory.changed.connect(_on_items_changed)


func _on_tile_clicked(tile: Vector2i) -> void:
	var ability := get_selected_ability()

	if ability.is_valid_tile(self, tile):
		var mana_cost := ability.get_mana_cost(self, tile)

		if mana.current >= mana_cost:
			grid.hide_mana_cost()
			mana.current -= mana_cost
			CombatState.is_waiting_for_player_input = false
			await ability.perform(self, tile)
			clear_selected_ability()
			CombatState.is_waiting_for_player_input = true


func _on_tile_hovered(tile: Vector2i) -> void:
	var ability := get_selected_ability()

	if ability.is_valid_tile(self, tile):
		grid.show_mana_cost(ability.get_mana_cost(self, tile))


func _on_button_end_turn_pressed() -> void:
	CombatState.is_waiting_for_player_input = false
	if CombatState.is_running:
		_turn_ended.emit()
	else:
		CombatState.run()


func _on_left_tile(_tile: Vector2i) -> void:
	loot_container.current_lootbag = null


func _on_entered_tile(tile: Vector2i) -> void:
	for lootbag in grid.get_nodes_on_tile(tile, Lootbag):
		loot_container.current_lootbag = lootbag
		break


func perform_turn() -> void:
	var player_state := PlayerState.get_instance()
	player_state.begin_turn()

	for equipement_slot in equipement_slots:
		equipement_slot.begin_turn(self)

	_process_status_effects()
	status_bar.update()

	CombatState.is_waiting_for_player_input = true

	await _turn_ended


func take_damage(value: int) -> void:
	health.current -= value
	await super.take_damage(value)


func heal(value: int) -> void:
	health.current += value


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


func _on_items_changed(_items: Array[Item]) -> void:
	status_bar.update()
