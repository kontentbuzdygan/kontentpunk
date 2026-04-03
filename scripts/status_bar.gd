class_name StatusBar
extends HFlowContainer

const MAX_ICONS: int = 4


func update() -> void:
	var actor: Actor = get_parent()
	var actor_statuses := actor.active_status_effects + actor.passive_status_effects
	for child in get_children():
		remove_child(child)
		child.queue_free()

	for status_wrapper in actor_statuses:
		if get_child_count() >= MAX_ICONS:
			break
		var texture_rect := TextureRect.new()
		texture_rect.texture = status_wrapper.status_effect.icon
		add_child(texture_rect)

	if not is_instance_of(actor, Player) || get_child_count() >= MAX_ICONS:
		return

	## Handle debuffs applied as penalties from items
	var items: Array[Item] = PlayerState.get_instance().get_items()
	for item in items:
		if item.penalties.is_empty() || not item.is_penalty_activated:
			continue

		for penalty in item.penalties:
			if get_child_count() >= MAX_ICONS:
				break

			var texture_rect := TextureRect.new()
			texture_rect.texture = penalty.icon
			add_child(texture_rect)
