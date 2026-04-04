class_name ApplyPenaltyAbilityEffect
extends AbilityEffect

var status_effect: StatusEffect
var item: Item

func _init(status_effect_: StatusEffect, item_: Item) -> void:
    status_effect = status_effect_
    item = item_

func queue(actor: Actor, target_tile: Vector2i) -> void:
    if randf() <= status_effect.apply_chance:
        CombatState.get_instance().queue_action(CombatAction.ApplyStatusEffect.new(actor, status_effect, target_tile))
