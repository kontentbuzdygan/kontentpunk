class_name MoveAbilityEffect
extends AbilityEffect
## Moves the actor to the selected tile


func queue(actor: Actor, target_tile: Vector2i) -> void:
	CombatState.get_instance().queue_action(CombatAction.Move.new(actor, target_tile))
