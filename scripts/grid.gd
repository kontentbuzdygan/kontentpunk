class_name Grid
extends TileMapLayer

var _last_active_tile: Vector2i = Vector2i.ZERO
var active_tile: Vector2i = Vector2i.ZERO

signal tile_hovered(tile: Vector2i)
signal tile_clicked(tile: Vector2i)

@onready var player: Player = find_children("", "Player")[0]


func _process(_delta: float) -> void:
	active_tile = local_to_map(get_local_mouse_position())

	if get_cell_tile_data(active_tile):
		$Highlight.position = map_to_local(active_tile)
		$Highlight.visible = true

		if active_tile != _last_active_tile:
			$Highlight/AnimatedSprite2D.frame = 0
			hide_mana_cost()
			tile_hovered.emit(active_tile)
	else:
		$Highlight.visible = false

	_last_active_tile = active_tile


func _input(event: InputEvent) -> void:
	if CombatState.get_instance().is_in_progress():
		return

	if event.is_action_pressed("2d_select") and get_cell_tile_data(active_tile):
		tile_clicked.emit(active_tile)


func get_node_tile(node: Node2D) -> Vector2i:
	var relative_position := node.global_position - global_position
	return local_to_map(relative_position)


func get_nodes_on_tile(tile: Vector2i) -> Array[Node2D]:
	var found: Array[Node2D] = []

	for node in get_children():
		if node is Node2D and get_node_tile(node) == tile:
			found.append(node)

	return found


func is_tile_occupied(tile: Vector2i) -> bool:
	for node in get_nodes_on_tile(tile):
		if node.is_in_group(&"occupies_tile"):
			return true

	return false


func get_random_tile() -> Vector2i:
	return get_used_cells().pick_random()


func find_tile_with(node_type: Variant) -> Vector2i:
	for node in get_children():
		if is_instance_of(node, node_type):
			return get_node_tile(node)

	return Vector2i(-1, -1)


func show_mana_cost(cost: int) -> void:
	$Highlight/ManaCostDisplay.cost = cost
	$Highlight/ManaCostDisplay.visible = true


func hide_mana_cost() -> void:
	$Highlight/ManaCostDisplay.visible = false
