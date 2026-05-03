class_name LevelTree
extends Control

func _ready() -> void:
	create_buttons(LevelManager.tree)
	draw_graph(LevelManager.tree)


func create_buttons(tree: Array[Array]) -> void:
	for level in tree:
		for node in level as Array[LevelManager.LevelNode]:
			node.button = LevelButton.new(node.index)
			add_child(node.button)


func draw_graph(tree_: Array[Array]) -> void:
	var resolution := get_window().size
	var y_offset := 40
	for level in tree_:
		for node_index in range(level.size()):
			var node := level[node_index] as LevelManager.LevelNode
			var button := node.button
			var x := (resolution[0] * (node_index + 1)) / (level.size() + 1)
			var y := resolution[1] - (node.level + 1) * y_offset
			button.position.x = x
			button.position.y = y

			for parent in node.parents:
				var line := Line2D.new()
				line.width = 1
				line.add_point(Vector2(button.position.x + button.size[0] / 2, button.position.y + button.size[1] / 2))
				line.add_point(Vector2(parent.button.position.x + parent.button.size[0] / 2, parent.button.position.y + parent.button.size[1] / 2))
				add_child(line)


func _on_check_button_toggled(toggled_on: bool) -> void:
	for child in get_children():
		if is_instance_of(child, Line2D):
			remove_child(child)
			child.queue_free()

	if toggled_on:
		draw_graph(LevelManager.tree)
	else:
		draw_graph(LevelManager.unsorted_tree)
