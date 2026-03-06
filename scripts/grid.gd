@tool
extends TextureRect

@export var dimensions: Vector2i = Vector2i(12, 12)
var active_tile: Vector2i = Vector2i.ZERO

signal tile_clicked(tile: Vector2i)


func _ready() -> void:
	$HighlightedTile.visible = false
	update_size()

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_size()
	else:
		active_tile = Vector2i(get_local_mouse_position() / texture.get_size())
		$HighlightedTile.position = Vector2(active_tile) * texture.get_size()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("2d_select") and $HighlightedTile.visible:
		tile_clicked.emit(active_tile)


func _on_mouse_entered() -> void:
	$HighlightedTile.visible = true


func _on_mouse_exited() -> void:
	$HighlightedTile.visible = false


func update_size() -> void:
	size = Vector2(dimensions) * texture.get_size()
