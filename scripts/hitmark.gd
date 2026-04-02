class_name Hitmark
extends Control

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var label: Label = $Label

func show_hitmark(value: int) -> void:
	label.text = str(value)
	animation_tree.set("parameters/Transition/transition_request", "hit")
	await animation_tree.get("parameters/Transition/current_state")


func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	get_parent().remove_child(self)
	queue_free()
