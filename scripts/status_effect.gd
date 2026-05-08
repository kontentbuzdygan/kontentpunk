@tool
class_name StatusEffect
extends Resource

@export var name: String
@export var icon: Texture2D
@export var animation: PackedScene

@export var duration_turns: int
## Target takes this much damage each turn while the effect is active
@export var damage_per_turn: int
## Added to the target's max health for the duration of the effect
@export var max_health_change: int


## Called when the effect is first received
func apply(actor: Actor) -> void:
	await _play_animation(actor, &"apply")

	if max_health_change != 0 and actor is Player:
		actor.health.maximum += max_health_change


## Called on each turn while the effect is active
func on_turn(actor: Actor) -> void:
	_play_animation(actor, &"on_turn")

	if damage_per_turn > 0:
		await actor.take_damage(damage_per_turn, name)


## Called when the duration of the effect elapses
func remove(actor: Actor) -> void:
	_play_animation(actor, &"remove")

	if max_health_change != 0 and actor is Player:
		actor.health.maximum -= max_health_change


func _play_animation(actor: Actor, animation_name: StringName) -> void:
	var instance := animation.instantiate()
	actor.add_child(instance)

	if instance is StatusEffectAnimationPlayer:
		await instance.play_animation(animation_name)
	elif instance is GPUParticles2D and animation_name == &"on_turn":
		instance.emitting = true
		await instance.finished

	actor.remove_child(instance)
	instance.queue_free()


func _get_custom_preview_texture() -> Texture2D:
	return icon
