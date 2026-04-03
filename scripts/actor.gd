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
	CombatState.get_instance().add_actor(self)

	_audio_stream_player = AudioStreamPlayer.new()
	_audio_stream_player.bus = sound_effect_bus
	add_child(_audio_stream_player)


func get_current_tile() -> Vector2i:
	return grid.get_node_tile(self)


func move_to(tile: Vector2i) -> bool:
	if not grid.is_tile_occupied(tile):
		CombatState.get_instance().queue_action(CombatAction.Move.new(self, tile))
		return true

	return false


func execute(action: CombatAction) -> void:
	## If enemy is already dead, don't wait on their action
	if action.actor is Enemy and action.actor.health == 0:
		return

	if action is CombatAction.EndTurn:
		return

	if action is CombatAction.Move:
		left_tile.emit(get_current_tile())
		play_sound(move_sound)
		# await grid_animation_player.move_to(action.target_tile)
		await execute_move(action.target_tile)
		entered_tile.emit(action.target_tile)
		return

	if action is CombatAction.DealDamage:
		for node in grid.get_nodes_on_tile(action.target_tile):
			if node is Actor:
				await node.take_damage(action.value)
		return

	if action is CombatAction.ApplyStatusEffect:
		for node in grid.get_nodes_on_tile(action.target_tile):
			if node is Actor:
				node.apply_status_effect(action.status_effect)
		return

	if action is CombatAction.Bleed:
		play_sound(action.sound_effect)
		_emit_status_effect_particles(action.particles)
		await action.actor.take_damage(action.value)
		return

	assert(false, "invalid action %s for %s" % [action, self])


func begin_turn() -> void:
	pass


func take_damage(value: int) -> void:
	print("%s took %d damage" % [self, value])
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
	if status_effect.is_active:
		var existing_status_effect: Array[StatusEffectDuration] = []
		existing_status_effect.assign(
			active_status_effects.filter(
				func (active_status_wrapper: StatusEffectDuration) -> bool: return active_status_wrapper.status_effect == status_effect
			)
		)

		if not existing_status_effect.size():
			var status_wrapper := StatusEffectDuration.new(status_effect)
			active_status_effects.append(status_wrapper)
		else:
			## If status effect is already applied to the actor, extend its duration
			existing_status_effect[0].duration = status_effect.duration
	else:
		var status_wrapper := StatusEffectDuration.new(status_effect)
		passive_status_effects.append(status_wrapper)
	status_bar.update()


func _process_status_effects() -> void:
	for status_wrapper in active_status_effects + passive_status_effects:
		status_wrapper.queue(self)
		if status_wrapper.duration == 0:
			remove_status_effect(status_wrapper)


func remove_status_effect(status_wrapper: StatusEffectDuration) -> void:
	if status_wrapper.status_effect.is_active:
		active_status_effects.remove_at(active_status_effects.find(status_wrapper))
	else:
		passive_status_effects.remove_at(passive_status_effects.find(status_wrapper))
	status_bar.update()


func _emit_status_effect_particles(particles_scene: PackedScene) -> void:
	var particles: GPUParticles2D = particles_scene.instantiate()
	add_child(particles)
	particles.emitting = true
	particles.finished.connect(func() -> void:
		remove_child(particles)
		particles.queue_free()
	)


func _show_hitmark(value: int) -> void:
	var hitmark: Hitmark = hitmark_scene.duplicate().instantiate()
	grid.add_child_on_tile(hitmark, self.get_current_tile())
	hitmark.label.text = str(value)


func execute_move(target_tile: Vector2i) -> void:
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
	
	func queue(actor: Actor) -> void:
		status_effect.queue(actor)
		duration = max(duration - 1, 0)