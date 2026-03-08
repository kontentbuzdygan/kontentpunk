extends Node

@export_group("Cursor Arrow", "cursor_arrow")
@export var cursor_arrow_image: Image
@export var cursor_arrow_hotspot: Vector2i

@export_group("Cursor Pointer", "cursor_pointer")
@export var cursor_pointer_image: Image
@export var cursor_pointer_hotspot: Vector2i

@export_group("UI Sounds", "ui_sound")
@export var ui_sound_click: AudioStream
@export var ui_sound_toggle_on: AudioStream
@export var ui_sound_toggle_off: AudioStream


func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_arrow_image, Input.CURSOR_ARROW, cursor_arrow_hotspot)
	Input.set_custom_mouse_cursor(
		cursor_pointer_image, Input.CURSOR_POINTING_HAND, cursor_pointer_hotspot
	)

	get_tree().node_added.connect(_on_node_added)
	for button in get_tree().root.find_children("", "Button", true, false):
		set_button_sounds(button)


func _on_node_added(node: Node) -> void:
	if node is Button:
		set_button_sounds(node)


func set_button_sounds(button: Button) -> void:
	button.pressed.connect(_on_button_pressed.bind(button))
	button.toggled.connect(_on_button_toggled.bind(button))


func _on_button_pressed(button: Button) -> void:
	if not button.toggle_mode:
		$UISounds.stream = ui_sound_click
		$UISounds.play()


func _on_button_toggled(value: bool, button: Button) -> void:
	if button.toggle_mode:
		if value:
			$UISounds.stream = ui_sound_toggle_on
			$UISounds.play()
		else:
			$UISounds.stream = ui_sound_toggle_off
			$UISounds.play()
