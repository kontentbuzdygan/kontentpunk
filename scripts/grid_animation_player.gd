class_name GridAnimationPlayer
extends AnimationPlayer

@onready var grid: Grid = find_parent("Grid")


func move_to(tile: Vector2i, then: Callable) -> void:
	var target_position := grid.map_to_local(tile)

	var animation := get_animation(&"move")
	var track_idx := animation.find_track(".:position", Animation.TYPE_VALUE)
	animation.track_set_key_value(track_idx, 0, get_parent().position)
	animation.track_set_key_value(track_idx, 1, target_position)

	play_and_then(&"move", then)


func play_and_then(animation: StringName, then: Callable) -> void:
	animation_finished.connect(then.unbind(1), CONNECT_ONE_SHOT)
	play(animation)
