class_name StatusEffectReceiver
extends Node

var _active_status_effects: Array[ActiveStatusEffect]


func get_active_status_effects() -> Array[ActiveStatusEffect]:
	return _active_status_effects.duplicate()


func apply(effect: StatusEffect) -> void:
	var matching_effects: Array[ActiveStatusEffect] = _active_status_effects.filter(
		func(e: ActiveStatusEffect) -> bool: return e.effect == effect
	)

	if matching_effects.is_empty():
		_active_status_effects.append(ActiveStatusEffect.new(effect))
	else:
		matching_effects[0].duration_turns = effect.duration_turns


func update(actor: Actor) -> void:
	for effect in _active_status_effects:
		effect.effect.apply(actor)
		effect.duration_turns -= 1

		if effect.duration_turns == 0:
			effect.effect.remove(actor)
			_active_status_effects.erase(effect)


class ActiveStatusEffect:
	var effect: StatusEffect
	var duration_turns: int

	func _init(effect_: StatusEffect) -> void:
		effect = effect_
		duration_turns = effect.duration_turns
