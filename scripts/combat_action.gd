@abstract class_name CombatAction

var actor: Actor


func _init(actor_: Actor) -> void:
	actor = actor_


class EndTurn:
	extends CombatAction

	func _to_string() -> String:
		return "<end turn>"


class Move:
	extends CombatAction

	var target_tile: Vector2i

	func _init(actor_: Actor, target_tile_: Vector2i) -> void:
		super._init(actor_)
		target_tile = target_tile_

	func _to_string() -> String:
		return "<move to %s>" % target_tile


class DealDamage:
	extends CombatAction

	var target_tile: Vector2i
	var value: int

	func _init(actor_: Actor, target_tile_: Vector2i, value_: int) -> void:
		super._init(actor_)
		target_tile = target_tile_
		value = value_

	func _to_string() -> String:
		return "<deal %d damage to %s>" % [value, target_tile]


class HealSelf:
	extends CombatAction

	var value: int

	func _init(actor_: Actor, value_: int) -> void:
		super._init(actor_)
		value = value_

	func _to_string() -> String:
		return "<heal self by %d>" % value


class ApplyStatusEffect:
	extends CombatAction

	var target_tile: Vector2i
	var status_effect: StatusEffect

	func _init(actor_: Actor, status_effect_: StatusEffect, target_tile_: Vector2i) -> void:
		super._init(actor_)
		status_effect = status_effect_
		target_tile = target_tile_

	func _to_string() -> String:
		return "<applied bleeding>"


class Bleed:
	extends CombatAction

	var value: int
	var particles: PackedScene
	var sound_effect: AudioStream

	func _init(actor_: Actor, value_: int, particles_: PackedScene, sound_effect_: AudioStream) -> void:
		super._init(actor_)
		value = value_
		particles = particles_
		sound_effect = sound_effect_

	func _to_string() -> String:
		return "<bleed dealt %d damage>" % value