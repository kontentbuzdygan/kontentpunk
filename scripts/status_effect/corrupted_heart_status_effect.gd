class_name CorruptedHeartStatusEffect
extends StatusEffect

@export var max_health_change := -1


func apply(actor: Actor) -> void:
	var animation_instance: StatusEffectAnimationPlayer = animation.instantiate()
	if actor is Player:
		await actor.play_status_animation(animation_instance, &"apply")
		actor.health.maximum += max_health_change


func remove(actor: Actor) -> void:
	var animation_instance: StatusEffectAnimationPlayer = animation.instantiate()
	if actor is Player:
		await actor.play_status_animation(animation_instance, &"remove")
		actor.health.maximum -= max_health_change
