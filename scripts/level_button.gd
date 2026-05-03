class_name LevelButton
extends Button

var index: int

func _init(index_: int) -> void:
	index = index_
	text = str(index)
	z_index = 999

	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	SceneManager.goto_scene("res://levels/main.tscn")
