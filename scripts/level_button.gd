class_name LevelButton
extends Button

var level_node: LevelManager.LevelNode

func _init(level_node_: LevelManager.LevelNode) -> void:
	level_node = level_node_
	text = str(level_node.index)
	z_index = 999
	toggle_mode = true

	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if level_node == LevelManager.current_player_node:
		return
	LevelManager.current_player_node = level_node
	SceneManager.goto_scene("res://levels/main.tscn")
