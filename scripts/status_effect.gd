@abstract
class_name StatusEffect
extends Resource

@export var duration: int = 3
@export var apply_chance: float = 0.5:
    get():
        return apply_chance
    set(value):
        apply_chance = clamp(value, 0.0, 1.0)

@export var is_active: bool = false
@export var particles: PackedScene


@abstract func queue(actor: Actor) -> void