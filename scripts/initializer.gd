extends Node

@export_group("Cursor Arrow", "cursor_arrow")
@export var cursor_arrow_image: Image
@export var cursor_arrow_hotspot: Vector2i

@export_group("Cursor Pointer", "cursor_pointer")
@export var cursor_pointer_image: Image
@export var cursor_pointer_hotspot: Vector2i

@export_group("Cursor Can Grab", "cursor_can_grab")
@export var cursor_can_grab_image: Image
@export var cursor_can_grab_hotspot: Vector2i

@export_group("Cursor Grabbing", "cursor_grabbing")
@export var cursor_grabbing_image: Image
@export var cursor_grabbing_hotspot: Vector2i

@export_group("Cursor Can't Drop", "cursor_cant_drop")
@export var cursor_cant_drop_image: Image
@export var cursor_cant_drop_hotspot: Vector2i

@export_group("UI Sounds", "ui_sound")
@export var ui_sound_click: AudioStream
@export var ui_sound_toggle_on: AudioStream
@export var ui_sound_toggle_off: AudioStream


func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_arrow_image, Input.CURSOR_ARROW, cursor_arrow_hotspot)
	Input.set_custom_mouse_cursor(
		cursor_pointer_image, Input.CURSOR_POINTING_HAND, cursor_pointer_hotspot
	)
	Input.set_custom_mouse_cursor(cursor_can_grab_image, Input.CURSOR_MOVE, cursor_can_grab_hotspot)
	Input.set_custom_mouse_cursor(cursor_grabbing_image, Input.CURSOR_DRAG, cursor_grabbing_hotspot)
	Input.set_custom_mouse_cursor(
		cursor_grabbing_image, Input.CURSOR_CAN_DROP, cursor_grabbing_hotspot
	)
	Input.set_custom_mouse_cursor(
		cursor_cant_drop_image, Input.CURSOR_FORBIDDEN, cursor_cant_drop_hotspot
	)

	get_tree().node_added.connect(_on_node_added)
	for button in get_tree().root.find_children("", "Button", true, false):
		update_button(button)


func _on_node_added(node: Node) -> void:
	if node is Button:
		update_button(node)


func update_button(button: Button) -> void:
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(_on_button_pressed.bind(button))
	button.toggled.connect(_on_button_toggled.bind(button))


func _on_button_pressed(button: Button) -> void:
	# Handle removed buttons on scene changes
	if not button.is_inside_tree():
		return

	if not button.toggle_mode:
		$UISounds.stream = ui_sound_click
		$UISounds.play()


func _on_button_toggled(value: bool, button: Button) -> void:
	# Handle removed buttons on scene changes
	if not button.is_inside_tree():
		return

	if button.toggle_mode:
		if value:
			$UISounds.stream = ui_sound_toggle_on
			$UISounds.play()
		else:
			$UISounds.stream = ui_sound_toggle_off
			$UISounds.play()
