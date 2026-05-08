class_name Actor
extends Node2D

@export var is_alive: bool = true:
	get:
		return is_alive
	set(value):
		is_alive = value
		visible = value

@export var sound_effect_bus: StringName = &"Sound Effects"
@export var move_sound: AudioStream
@export var hurt_sound: AudioStream
@export var hitmark_scene: PackedScene
## Actors with lower values will before actors with higher values
@export var turn_order: int

@onready var grid: Grid = find_parent("Grid")
@onready var status_bar: StatusBar = $StatusBar
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var status_effect_receiver: StatusEffectReceiver = $StatusEffectReceiver

var tween: Tween

var is_idle: bool = true
var is_moving: bool = false

var _audio_stream_player: AudioStreamPlayer

signal left_tile(tile: Vector2i)
signal entered_tile(tile: Vector2i)
signal health_changed


func _ready() -> void:
	CombatState.add_actor(self)

	_audio_stream_player = AudioStreamPlayer.new()
	_audio_stream_player.bus = sound_effect_bus
	add_child(_audio_stream_player)


func get_current_tile() -> Vector2i:
	return grid.get_node_tile(self)


func perform_turn() -> void:
	pass


func take_damage(value: int, source: String = "") -> void:
	if source:
		print(name, " took ", value, " damage from ", source)
	else:
		print(name, " took ", value, " damage")

	play_sound(hurt_sound, 0.1)
	_show_hitmark(value)
	animation_tree["parameters/playback"].travel(&"hurt")
	health_changed.emit()

	await animation_tree.animation_finished
	await get_tree().create_timer(0.5).timeout


func play_sound(sound: AudioStream, delay: float = 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	_audio_stream_player.stream = sound
	_audio_stream_player.play()


func apply_status_effect(effect: StatusEffect) -> void:
	status_effect_receiver.apply(self, effect)
	status_bar.update()


func _process_status_effects() -> void:
	await status_effect_receiver.on_turn(self)
	status_bar.update()


func _show_hitmark(value: int) -> void:
	var hitmark: Hitmark = hitmark_scene.duplicate().instantiate()
	grid.add_child_on_tile(hitmark, self.get_current_tile())
	hitmark.label.text = str(value)


func move_to(target_tile: Vector2i) -> bool:
	if grid.is_tile_occupied(target_tile):
		return false

	left_tile.emit(get_current_tile())
	play_sound(move_sound)

	var direction: Vector2 = Vector2(target_tile - get_current_tile()).normalized()
	set_moving_state(direction)

	var relative_tile := target_tile - get_current_tile()
	var distance := Utils.manhattan_length(relative_tile)
	var time_per_tile := 0.22

	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", grid.map_to_local(target_tile), distance * time_per_tile)
	await tween.finished

	set_idle_state()

	entered_tile.emit(target_tile)

	return true


func set_moving_state(direction: Vector2) -> void:
	is_moving = true
	is_idle = false

	animation_tree["parameters/idle/blend_position"] = direction
	animation_tree["parameters/run/blend_position"] = direction
	animation_tree["parameters/hurt/blend_position"] = direction


func set_idle_state() -> void:
	is_moving = false
	is_idle = true
