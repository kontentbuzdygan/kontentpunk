@tool
class_name ItemTooltip
extends Control

@export var text: String:
	get:
		return text
	set(value):
		text = value
		if is_node_ready():
			$Label.text = value


func _ready() -> void:
	if not Engine.is_editor_hint():
		$Label.text = text
