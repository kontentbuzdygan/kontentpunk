@abstract
class_name StatusEffect
extends Resource

@export var name: StringName = &"Status"
@export var duration: int = 3
@export var apply_chance: float = 0.5:
    get():
        return apply_chance
    set(value):
        apply_chance = clamp(value, 0.0, 1.0)

@export var is_active: bool = true
@export var is_penalty: bool = true
@export var particles: PackedScene
@export var sound_effect: AudioStream
@export var icon: Texture2D


@abstract func queue(actor: Actor) -> void
@abstract func remove() -> void
