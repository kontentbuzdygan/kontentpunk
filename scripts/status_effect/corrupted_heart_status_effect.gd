class_name CorruptedHeartStatusEffect
extends StatusEffect

@export var affected_hearts := 1

func queue(actor: Actor) -> void:
	CombatState.get_instance().queue_action(CombatAction.CorruptHeart.new(actor, affected_hearts, animation))


func remove(actor: Actor) -> void:
	CombatState.get_instance().queue_action(CombatAction.CorruptHeart.new(actor, -affected_hearts, animation))
