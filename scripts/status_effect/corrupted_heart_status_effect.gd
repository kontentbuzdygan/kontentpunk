class_name CorruptedHeartStatusEffect
extends StatusEffect

@export var base_value := 1

func queue(actor: Actor) -> void:
	CombatState.get_instance().queue_action(CombatAction.CorruptHeart.new(actor, base_value, animation))


func remove(actor: Actor) -> void:
	CombatState.get_instance().queue_action(CombatAction.CorruptHeart.new(actor, -base_value, animation))
