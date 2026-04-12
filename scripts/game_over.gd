extends Control


func _on_button_new_game_pressed() -> void:
	PlayerState.restart()
	SceneManager.goto_scene("res://levels/main.tscn")
