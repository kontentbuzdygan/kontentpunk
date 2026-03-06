@tool
class_name Grid
extends TextureRect

@export var dimensions: Vector2i = Vector2i(12, 12)
var active_tile: Vector2i = Vector2i.ZERO

signal tile_clicked(tile: Vector2i)


func _ready() -> void:
	$HighlightedTile.visible = false
	_update_size()

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_size()
	else:
		active_tile = Vector2i(get_local_mouse_position() / texture.get_size())
		$HighlightedTile.position = Vector2(active_tile) * texture.get_size()
		$HighlightedTile.visible = not State.is_input_locked()


func _input(event: InputEvent) -> void:
	if State.is_input_locked():
		return

	if event.is_action_pressed("2d_select") and $HighlightedTile.visible:
		tile_clicked.emit(active_tile)


func _on_mouse_entered() -> void:
	$HighlightedTile.visible = true


func _on_mouse_exited() -> void:
	$HighlightedTile.visible = false


func _update_size() -> void:
	size = Vector2(dimensions) * texture.get_size()


func get_tile_position(tile: Vector2i) -> Vector2:
	return Vector2(tile) * texture.get_size()
