class_name StatusBar
extends HFlowContainer

func add_status(icon: Texture2D):
	var texture_rect = TextureRect.new()
	texture_rect.texture = icon
	texture_rect.visible = true if get_child_count() < 4 else false
	add_child(texture_rect)


func remove_status(icon: Texture2D):
	for child in get_children():
		if child is TextureRect and child.texture == icon:
			remove_child(child)
			child.queue_free()
			break

	## Show last status icon if there were > 4 status effects
	var last_icon = get_child(3)
	if last_icon:
		last_icon.visible = true
