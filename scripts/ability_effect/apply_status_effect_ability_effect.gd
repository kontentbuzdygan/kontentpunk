class_name ApplyStatusEffectAbilityEffect
extends AbilityEffect

@export var status_effect: StatusEffect

func queue(actor: Actor, target_tile: Vector2i) -> void:
    if randf() <= status_effect.apply_chance:
        CombatState.get_instance().queue_action(CombatAction.ApplyStatusEffect.new(actor, status_effect, target_tile))
