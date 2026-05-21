class_name StatusBar
extends HFlowContainer

const MAX_STATUS_EFFECT_ICONS: int = 4


func update() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	var actor: Actor = get_parent()
	_show_status_effects(actor.status_effect_receiver.get_active_status_effects())

	if actor is Player:
		for slot in (actor as Player).equipement_slots:
			_show_status_effects(slot.status_effect_receiver.get_active_status_effects())


func _show_status_effects(effects: Array[StatusEffectReceiver.AppliedStatusEffect]) -> void:
	for effect in effects:
		if get_child_count() >= MAX_STATUS_EFFECT_ICONS:
			break

		var texture_rect := TextureRect.new()
		texture_rect.texture = effect.effect.icon
		add_child(texture_rect)
