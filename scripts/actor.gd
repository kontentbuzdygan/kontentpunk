class_name Actor
extends Node2D

@export var move_sound: AudioStream

@onready var grid: Grid = find_parent("Grid")
@onready var grid_animation_player: GridAnimationPlayer = find_children("", "GridAnimationPlayer")[0]

var _audio_stream_player: AudioStreamPlayer


func _ready() -> void:
	_audio_stream_player = AudioStreamPlayer.new()
	add_child(_audio_stream_player)


func get_current_tile() -> Vector2i:
	return grid.get_node_tile(self)


func move_to(tile: Vector2i) -> bool:
	if grid.get_nodes_on_tile(tile).is_empty():
		CombatState.queue_action(CombatAction.Move.new(self, tile))
		return true

	return false


func execute(action: CombatAction) -> void:
	if action is CombatAction.Move:
		play_sound(move_sound)
		await grid_animation_player.move_to(action.target_tile)
		return

	if action is CombatAction.DealDamage:
		for node in grid.get_nodes_on_tile(action.target_tile):
			if node is Actor:
				await node.take_damage(action.value)
		return

	assert(false, "invalid action %s for %s" % [action, self])


func take_damage(value: int) -> void:
	print("%s took %d damage" % [self, value])


func play_sound(sound: AudioStream) -> void:
	_audio_stream_player.stream = sound
	_audio_stream_player.play()
