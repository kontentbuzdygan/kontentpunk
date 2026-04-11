class_name CorruptedHeartStatusEffect
extends StatusEffect

@export var base_value := 1

func queue(actor: Actor) -> void:
	CombatState.get_instance().queue_action(CombatAction.CorruptHeart.new(actor, base_value, animation, apply_sound_effect, revert_sound_effect))


func remove(actor: Actor) -> void:
	CombatState.get_instance().queue_action(CombatAction.CorruptHeart.new(actor, -base_value, animation, apply_sound_effect, revert_sound_effect))
