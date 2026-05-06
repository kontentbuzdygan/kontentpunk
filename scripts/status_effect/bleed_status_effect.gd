class_name BleedStatusEffect
extends StatusEffect

@export var damage: int = 1


func _ready() -> void:
	self.is_active = true


func apply(actor: Actor) -> void:
	actor.emit_status_effect_particles(animation)
	actor.take_damage(damage)


func remove(_actor: Actor) -> void:
	pass
