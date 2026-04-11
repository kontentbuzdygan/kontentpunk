class_name StatusEffectReceiver
extends Node2D

var status_effects: Array[StatusEffectDuration]

func apply_status_effect(status_effect: StatusEffect) -> void:
	var existing_status_effect: Array[StatusEffectDuration] = []
	existing_status_effect.assign(
		status_effects.filter(
			func (active_status_wrapper: StatusEffectDuration) -> bool: return active_status_wrapper.status_effect == status_effect
		)
	)

	if existing_status_effect.is_empty():
		var status_wrapper: StatusEffectDuration

		if status_effect.is_active:
			status_wrapper = OverTimeStatusEffect.new(status_effect)
		else:
			status_wrapper = PersistentOneshotStatusEffect.new(status_effect)
		status_effects.append(status_wrapper)
	else:
		## If status effect is already applied to the actor, extend its duration
		existing_status_effect[0].duration = status_effect.duration


func _process_status_effects(actor: Actor) -> void:
	for status_wrapper in status_effects:
		status_wrapper.queue(actor)
		if status_wrapper.duration == 0:
			status_wrapper.remove(actor)
			remove_status_effect(status_wrapper)


func remove_status_effect(status_wrapper: StatusEffectDuration) -> void:
	status_effects.remove_at(status_effects.find(status_wrapper))


@abstract
class StatusEffectDuration:
	var status_effect: StatusEffect
	var duration: int

	func _init(status_effect_: StatusEffect) -> void:
		status_effect = status_effect_
		duration = status_effect.duration

	func remove(actor: Actor) -> void:
		status_effect.remove(actor)
	
	@abstract
	func queue(actor: Actor) -> void


class OverTimeStatusEffect:
	extends StatusEffectDuration

	func _init(status_effect_: StatusEffect) -> void:
		super._init(status_effect_)

	func queue(actor: Actor) -> void:
		status_effect.queue(actor)
		duration = max(duration - 1, 0)


class PersistentOneshotStatusEffect:
	extends StatusEffectDuration

	var is_applied: bool = false

	func _init(status_effect_: StatusEffect) -> void:
		super._init(status_effect_)

	func queue(actor: Actor) -> void:
		if not is_applied:
			status_effect.queue(actor)
			is_applied = true
		duration = max(duration - 1, 0)
