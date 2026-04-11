class_name BleedStatusEffect
extends StatusEffect

@export var base_value: int = 1

func _ready() -> void:
	self.is_active = true


func queue(actor: Actor) -> void:
	CombatState.get_instance().queue_action(CombatAction.Bleed.new(actor, base_value, particles, sound_effect))


func remove() -> void:
	pass