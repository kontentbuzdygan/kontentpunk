class_name StatusEffectReceiver
extends Node2D

var status_effects: Array[StatusEffectWrapper]

func apply_status_effect(status_effect: StatusEffect) -> void:
	var existing_status_effect: Array[StatusEffectWrapper] = []
	existing_status_effect.assign(
		status_effects.filter(
			func (active_status_wrapper: StatusEffectWrapper) -> bool: return active_status_wrapper.status_effect == status_effect
		)
	)

	if not existing_status_effect.size():
		var status_wrapper: StatusEffectWrapper

		if status_effect.is_active:
			status_wrapper = ActiveStatusEffectWrapper.new(status_effect)
		else:
			status_wrapper = PassiveStatusEffectWrapper.new(status_effect)
		status_effects.append(status_wrapper)
	else:
		## If status effect is already applied to the actor, extend its duration
		existing_status_effect[0].duration = status_effect.duration


func _process_status_effects(actor: Actor) -> void:
	for status_wrapper in status_effects:
		status_wrapper.queue(actor)
		if status_wrapper.duration == 0:
			status_wrapper.remove()
			remove_status_effect(status_wrapper)


func remove_status_effect(status_wrapper: StatusEffectWrapper) -> void:
	status_effects.remove_at(status_effects.find(status_wrapper))


@abstract
class StatusEffectWrapper:
	var status_effect: StatusEffect
	var duration: int

	func _init(status_effect_: StatusEffect) -> void:
		status_effect = status_effect_
		duration = status_effect.duration

	func remove() -> void:
		status_effect.remove()
	
	@abstract
	func queue(actor: Actor) -> void


class ActiveStatusEffectWrapper:
	extends StatusEffectWrapper

	func _init(status_effect_: StatusEffect) -> void:
		super._init(status_effect_)

	func queue(actor: Actor) -> void:
		status_effect.queue(actor)
		duration = max(duration - 1, 0)


class PassiveStatusEffectWrapper:
	extends StatusEffectWrapper

	var is_applied: bool = false

	func _init(status_effect_: StatusEffect) -> void:
		super._init(status_effect_)

	func queue(actor: Actor) -> void:
		if not is_applied:
			status_effect.queue(actor)
			is_applied = true
		duration = max(duration - 1, 0)
