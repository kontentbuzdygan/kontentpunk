class_name LevelSelectButton
extends Button


func _on_pressed() -> void:
	SceneManager.goto_scene("res://levels/main.tscn")
