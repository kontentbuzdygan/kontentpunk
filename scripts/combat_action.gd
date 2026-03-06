class_name CombatAction

var actor: Actor

class Move extends CombatAction:
	var target_tile: Vector2i

	func _init(actor_: Actor, target_tile_: Vector2i) -> void:
		actor = actor_
		target_tile = target_tile_
