class_name GridAnimationPlayer
extends AnimationPlayer

@onready var grid: Grid = find_parent("Grid")


func move_to(tile: Vector2i, then: Callable) -> void:
	var target_position := grid.get_tile_position(tile)

	var animation := get_animation(&"move")
	var track_idx := animation.find_track(".:position", Animation.TYPE_VALUE)
	animation.track_set_key_value(track_idx, 0, get_parent().position)
	animation.track_set_key_value(track_idx, 1, target_position)

	animation_finished.connect(then.unbind(1), CONNECT_ONE_SHOT)
	play(&"move")
