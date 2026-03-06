class_name Player
extends Actor

@export var mana: PlayerResource


func move_to(tile: Vector2i) -> void:
	if mana.current > 0:
		mana.current -= 1
		super.move_to(tile)
