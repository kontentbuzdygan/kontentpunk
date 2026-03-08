@abstract class_name CombatAction

var actor: Actor


func _init(actor_: Actor) -> void:
	actor = actor_


class Move:
	extends CombatAction

	var target_tile: Vector2i

	func _init(actor_: Actor, target_tile_: Vector2i) -> void:
		super._init(actor_)
		target_tile = target_tile_

	func _to_string() -> String:
		return "<move to %s>" % target_tile


class EndTurn:
	extends CombatAction

	func _to_string() -> String:
		return "<end turn>"
