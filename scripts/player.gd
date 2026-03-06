class_name Player
extends Actor

@export var mana: PlayerResource


func move_to(tile: Vector2i) -> void:
	var current_tile := get_current_tile()

	if current_tile.x != tile.x and current_tile.y != tile.y:
		return

	if mana.current < 1:
		return

	mana.current -= 1
	super.move_to(tile)
