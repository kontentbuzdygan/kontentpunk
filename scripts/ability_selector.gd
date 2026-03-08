@tool
class_name AbilitySelector
extends VBoxContainer

@export var ability: Ability:
	get:
		return _ability
	set(value):
		if _ability == value:
			return

		if _ability and _ability.changed.is_connected(update_children):
			_ability.changed.disconnect(update_children)

		_ability = value

		if _ability:
			_ability.changed.connect(update_children)

		update_children()

var _ability: Ability


func update_children() -> void:
	if _ability:
		%Button.icon = _ability.icon
		%ManaCostLabel.text = str(_ability.base_mana_cost)
	else:
		%Button.icon = null
		%ManaCostLabel.text = "0"
