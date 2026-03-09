@tool
class_name ItemTooltip
extends Control

var text: String = "":
	get():
		return text
	set(value):
		text = value
		update_children()

@onready var label = $Label


func update_children():
	if not is_node_ready():
		await ready
	if text:
		label.text = text
	else:
		label.text = ""
