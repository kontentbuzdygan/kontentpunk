class_name Grid
extends TileMapLayer

var _last_active_cell: Vector2i = Vector2i.ZERO
var active_cell: Vector2i = Vector2i.ZERO

signal tile_clicked(tile: Vector2i)


func _process(_delta: float) -> void:
	active_cell = local_to_map(get_local_mouse_position())

	if get_cell_tile_data(active_cell):
		$Highlight.position = map_to_local(active_cell)
		$Highlight.visible = true
		if active_cell != _last_active_cell:
			$Highlight/AnimatedSprite2D.frame = 0
	else:
		$Highlight.visible = false

	_last_active_cell = active_cell


func _input(event: InputEvent) -> void:
	if CombatState.is_in_progress():
		return

	if event.is_action_pressed("2d_select") and get_cell_tile_data(active_cell):
		tile_clicked.emit(active_cell)


func get_node_tile(node: Node2D) -> Vector2i:
	var relative_position := node.global_position - global_position
	return local_to_map(relative_position)


func get_nodes_on_tile(tile: Vector2i) -> Array[Node2D]:
	var found: Array[Node2D] = []

	for node in get_tree().get_nodes_in_group("occupies_tile"):
		if node is Node2D and is_ancestor_of(node) and get_node_tile(node) == tile:
			found.append(node)

	return found


func get_random_tile() -> Vector2i:
	return get_used_cells().pick_random()
