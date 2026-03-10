class_name DealDamageAbilityEffect
extends AbilityEffect
## Deals damage to each actor on the selected tile

@export var base_value: int = 1


func queue(actor: Actor, target_tile: Vector2i) -> void:
	CombatState.get_instance().queue_action(
		CombatAction.DealDamage.new(actor, target_tile, base_value)
	)
