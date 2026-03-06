extends Node

@export_group("Cursor Arrow", "cursor_arrow")
@export var cursor_arrow_image: Image
@export var cursor_arrow_hotspot: Vector2i

@export_group("Cursor Pointer", "cursor_pointer")
@export var cursor_pointer_image: Image
@export var cursor_pointer_hotspot: Vector2i


func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_arrow_image, Input.CURSOR_ARROW, cursor_arrow_hotspot)
	Input.set_custom_mouse_cursor(
		cursor_pointer_image, Input.CURSOR_POINTING_HAND, cursor_pointer_hotspot
	)
