class_name Actor
extends Node2D

@export var sound_effect_bus: StringName = &"Sound Effects"
@export var move_sound: AudioStream
@export var hurt_sound: AudioStream
@export var hitmark_scene: PackedScene

@onready var grid: Grid = find_parent("Grid")
# @onready var grid_animation_player: GridAnimationPlayer = find_children("", "GridAnimationPlayer")[0]
@onready var status_bar: StatusBar = find_children("StatusBar", "HFlowContainer")[0]
@onready var path_2d: Path2D = find_children("", "Path2D")[0]
@onready var path_follow_2d: PathFollow2D = find_children("", "PathFollow2D")[0]

var _audio_stream_player: AudioStreamPlayer

var passive_status_effects: Array[StatusEffect] = []
var active_status_effects: Array[StatusEffect] = []
var is_moving: bool = false

signal left_tile(tile: Vector2i)
signal entered_tile(tile: Vector2i)
signal health_changed
signal finished_moving


func _ready() -> void:
	_audio_stream_player = AudioStreamPlayer.new()
	_audio_stream_player.bus = sound_effect_bus
	add_child(_audio_stream_player)


func _process(delta: float) -> void:
	if path_2d.curve.point_count:
		path_follow_2d.progress_ratio += delta * 1
		print(self.global_position)

	if path_follow_2d.progress_ratio >= 0.9:
		is_moving = false
		path_2d.curve.clear_points()
		finished_moving.emit()
		set_process(false)


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


func take_damage(value: int) -> void:
	print("%s took %d damage" % [self, value])
	play_sound(hurt_sound, 0.1)
	_show_hitmark(value)

	health_changed.emit()
	#if grid_animation_player.has_animation(&"hurt"):
	#	await grid_animation_player.play_and_wait(&"hurt")


func play_sound(sound: AudioStream, delay: float = 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	_audio_stream_player.stream = sound
	_audio_stream_player.play()


func apply_status_effect(status_effect: StatusEffect) -> void:
	if status_effect.is_active:
		var existing_status_effect: Array[StatusEffect] = []
		existing_status_effect.assign(active_status_effects.filter(func (active_status): return active_status.name == status_effect.name))
		if not existing_status_effect.size():
			active_status_effects.append(status_effect)
			status_bar.add_status(status_effect.icon)
		else:
			## If status effect is already applied to the actor, extend its duration
			active_status_effects[active_status_effects.find(status_effect)].duration = status_effect.duration
	else:
		passive_status_effects.append(status_effect)


func _process_status_effects():
	for status_effect in active_status_effects:
		status_effect.queue(self)
		if status_effect.duration == 0:
			active_status_effects.remove_at(active_status_effects.find(status_effect))
			status_bar.remove_status(status_effect.icon)


func _emit_status_effect_particles(particles_scene: PackedScene) -> void:
	var particles: GPUParticles2D = particles_scene.instantiate()
	add_child(particles)
	particles.emitting = true
	particles.finished.connect(func():
		remove_child(particles)
		particles.queue_free()
	)


func _show_hitmark(value: int):
	var hitmark: Hitmark = hitmark_scene.duplicate().instantiate()
	grid.add_child_on_tile(hitmark, self.get_current_tile())
	hitmark.label.text = str(value)


func execute_move(target_tile: Vector2i) -> void:
	path_2d.curve.add_point(Vector2i.ZERO)
	path_2d.curve.add_point(grid.map_to_local(target_tile) - grid.map_to_local(get_current_tile()))
	print(path_2d.curve.get_point_position(1))
	is_moving = true
	set_process(true)
	await finished_moving
