class_name StatusBar
extends HFlowContainer

const MAX_ICONS: int = 4


func update() -> void:
	var actor: Actor = get_parent()
	var actor_statuses := actor.status_effect_receiver.status_effects
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

	var player: Player = actor as Player
	## Handle debuffs applied as penalties from items
	var equipement_slots: Array[ItemHolder] = player.equipement_slots
	for equipement_slot in equipement_slots:
		for penalty in equipement_slot.status_effect_receiver.status_effects:
			if get_child_count() >= MAX_ICONS:
				break

			var texture_rect := TextureRect.new()
			texture_rect.texture = penalty.status_effect.icon
			add_child(texture_rect)
