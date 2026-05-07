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
@onready var status_bar: StatusBar = find_children("StatusBar", "HFlowContainer")[0]
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var status_effect_receiver: StatusEffectReceiver = find_children("", "StatusEffectReceiver")[0]

var tween: Tween

var is_idle: bool = true
var is_moving: bool = false

var _audio_stream_player: AudioStreamPlayer

var passive_status_effects: Array[StatusEffectDuration] = []
var active_status_effects: Array[StatusEffectDuration] = []

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


func take_damage(value: int) -> void:
	print(name, " took ", value, " damage")
	play_sound(hurt_sound, 0.1)
	_show_hitmark(value)
	animation_tree["parameters/playback"].travel(&"hurt")
	health_changed.emit()

	await animation_tree.animation_finished


func play_sound(sound: AudioStream, delay: float = 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	_audio_stream_player.stream = sound
	_audio_stream_player.play()


func apply_status_effect(status_effect: StatusEffect) -> void:
	status_effect_receiver.apply_status_effect(status_effect)
	status_bar.update()


func _process_status_effects() -> void:
	status_effect_receiver._process_status_effects(self)
	status_bar.update()


func emit_status_effect_particles(particles_scene: PackedScene) -> void:
	var particles: GPUParticles2D = particles_scene.instantiate()
	add_child(particles)
	particles.emitting = true
	particles.finished.connect(func() -> void:
		remove_child(particles)
		particles.queue_free()
	)


func play_status_animation(instance: StatusEffectAnimationPlayer, animation_name: StringName) -> void:
	add_child(instance)
	await instance.play_animation(animation_name)
	remove_child(instance)
	instance.queue_free()


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


class StatusEffectDuration:
	var status_effect: StatusEffect
	var duration: int

	func _init(status_effect_: StatusEffect) -> void:
		status_effect = status_effect_
		duration = status_effect.duration

	func apply(actor: Actor) -> void:
		status_effect.apply(actor)
		duration = max(duration - 1, 0)
