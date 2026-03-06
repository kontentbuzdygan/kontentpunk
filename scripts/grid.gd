class_name Grid
extends TileMapLayer

@export var empty_tile_source_id: int = 0
@export var highlighted_tile_source_id: int = 1

var active_cell: Vector2i = Vector2i.ZERO

signal tile_clicked(tile: Vector2i)


func _process(_delta: float) -> void:
	active_cell = local_to_map(get_local_mouse_position())

	for cell in get_used_cells_by_id(highlighted_tile_source_id):
		set_cell(cell, empty_tile_source_id, Vector2i.ZERO)

	if not State.is_combat_in_progress():
		if get_cell_tile_data(active_cell):
			set_cell(active_cell, highlighted_tile_source_id, Vector2i.ZERO)


func _input(event: InputEvent) -> void:
	if State.is_combat_in_progress():
		return

	if event.is_action_pressed("2d_select"):
		tile_clicked.emit(active_cell)


func _on_mouse_entered() -> void:
	$HighlightedTile.visible = true


func _on_mouse_exited() -> void:
	$HighlightedTile.visible = false


func get_nodes_on_tile(tile: Vector2i) -> Array[Node2D]:
	var found: Array[Node2D] = []

	for node in get_tree().get_nodes_in_group("occupies_tile"):
		if node is Node2D and is_ancestor_of(node):
			var relative_position := (node as Node2D).global_position - global_position
			var node_tile := local_to_map(relative_position)

			if node_tile == tile:
				found.append(node)

	return found
