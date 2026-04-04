class_name Player
extends Actor

const MANA_COST_NOT_ALLOWED: int = -1

@export var end_turn_delay_seconds: float = 0.5
@export var abilities_button_group: ButtonGroup
@export var loot_container: LootContainer

@onready var health: PlayerResource = PlayerState.get_instance().health
@onready var mana: PlayerResource = PlayerState.get_instance().mana
@onready var equipement_slots: Array[ItemHolder] = [
	%Head,
	%Heart,
	%LArm,
	%RArm,
	%Spine,
	%LLeg,
	%RLeg,
]


func _ready() -> void:
	super._ready()
	grid.tile_clicked.connect(_on_tile_clicked)
	grid.tile_hovered.connect(_on_tile_hovered)

	left_tile.connect(_on_left_tile)
	entered_tile.connect(_on_entered_tile)

	var player_state := PlayerState.get_instance()
	player_state.items_changed.connect(_on_items_changed)


func _on_tile_clicked(tile: Vector2i) -> void:
	var ability := get_selected_ability()

	if ability.is_valid_tile(self, tile):
		var mana_cost := ability.get_mana_cost(self, tile)

		if mana.current >= mana_cost:
			grid.hide_mana_cost()
			mana.current -= mana_cost
			ability.perform(self, tile)
			clear_selected_ability()


func _on_tile_hovered(tile: Vector2i) -> void:
	var ability := get_selected_ability()

	if ability.is_valid_tile(self, tile):
		grid.show_mana_cost(ability.get_mana_cost(self, tile))


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


func begin_turn() -> void:
	var player_state := PlayerState.get_instance()
	player_state.begin_turn()

	for equipement_slot in equipement_slots:
		equipement_slot.begin_turn(self)

	_process_status_effects()
	status_bar.update()


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


func _on_items_changed(_items: Array[Item]) -> void:
	status_bar.update()
