extends AnimationPlayer

@onready var grid: Grid = find_parent("Grid")


func _ready() -> void:
	animation_finished.connect(_on_animation_finished)


func move_to(tile: Vector2i) -> void:
	var target_position := grid.get_tile_position(tile)

	var animation := get_animation(&"move")
	var track_idx := animation.find_track(".:position", Animation.TYPE_VALUE)
	animation.track_set_key_value(track_idx, 0, get_parent().position)
	animation.track_set_key_value(track_idx, 1, target_position)

	play(&"move")
	State.lock_input(self)


func _on_animation_finished(_animation_name: StringName) -> void:
	State.unlock_input(self)
