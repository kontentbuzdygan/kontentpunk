class_name StatusEffectReceiver
extends Node

var _active_status_effects: Array[ActiveStatusEffect]


func get_active_status_effects() -> Array[ActiveStatusEffect]:
	return _active_status_effects.duplicate()


func apply(actor: Actor, effect: StatusEffect) -> void:
	var matching_effects: Array[ActiveStatusEffect] = _active_status_effects.filter(
		func(e: ActiveStatusEffect) -> bool: return e.effect == effect
	)

	if matching_effects.is_empty():
		_active_status_effects.append(ActiveStatusEffect.new(effect))
		effect.apply(actor)
		print(get_parent().name, " received ", effect.name, " for ", effect.duration_turns, " turns")
	else:
		matching_effects[0].duration_turns = effect.duration_turns


func on_turn(actor: Actor) -> void:
	for effect in _active_status_effects:
		await effect.effect.on_turn(actor)
		effect.duration_turns -= 1

		if effect.duration_turns == 0:
			print(get_parent().name, "'s ", effect.effect.name, " ended")
			effect.effect.remove(actor)
			_active_status_effects.erase(effect)


class ActiveStatusEffect:
	var effect: StatusEffect
	var new: bool = true
	var duration_turns: int

	func _init(effect_: StatusEffect) -> void:
		effect = effect_
		duration_turns = effect.duration_turns
