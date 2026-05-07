class_name PlayerState
extends Node

@export var health: ActorResource
@export var mana: ActorResource
@export var money: ActorResource
@export var default_move_ability: Ability

@onready var inventory: Inventory = $Inventory

static var _instance: PlayerState


static func get_instance() -> PlayerState:
	assert(_instance != null, "PlayerState not initialized")
	return _instance


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_instance = self

	health.current_changed.connect(_on_health_changed)


func get_resource(type: ActorResource.Type) -> ActorResource:
	match type:
		ActorResource.Type.HEALTH:
			return health
		ActorResource.Type.MANA:
			return mana
		ActorResource.Type.MONEY:
			return money

	assert(false, "missing player resource type")
	return null


func _on_health_changed(value: int) -> void:
	if value <= 0:
		CombatState.stop()
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://objects/ui/game_over.tscn")


func begin_turn() -> void:
	mana.refill()
