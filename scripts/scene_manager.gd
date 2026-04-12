extends Node

var current_scene: Node = null

func _ready() -> void:
	current_scene = get_tree().root.get_child(-1)


func goto_scene(path: String) -> void:
	## https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html#creating-the-script
	## TLDR: `goto_function` will be called from the currently loaded scene that might still be running some code,
	## so it's dangerous to free the scene here.
	_deffered_goto_scene(path)


func _deffered_goto_scene(path: String) -> void:
	current_scene.queue_free()

	var s: PackedScene = ResourceLoader.load(path)
	current_scene = s.instantiate()

	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
