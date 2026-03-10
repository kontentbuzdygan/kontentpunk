class_name HealAbilityEffect
extends AbilityEffect
## Heals the actor

@export var base_value: int = 1


func queue(actor: Actor, _target_tile: Vector2i) -> void:
	CombatState.get_instance().queue_action(CombatAction.HealSelf.new(actor, base_value))
