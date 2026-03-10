extends Control


func _on_button_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/main.tscn")
