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


func _ready() -> void:
	if not Engine.is_editor_hint():
		PlayerState.get_resource(PlayerResource.Type.MANA).current_changed.connect(
			update_children.unbind(1)
		)


func update_children() -> void:
	if _ability:
		%Button.icon = _ability.icon
		%ManaCostLabel.text = str(_ability.base_mana_cost)
		update_label_colors()
	else:
		%Button.icon = null
		%ManaCostLabel.text = "0"


func update_label_colors() -> void:
	if Engine.is_editor_hint():
		return

	var mana := PlayerState.get_resource(PlayerResource.Type.MANA).current

	if mana < _ability.base_mana_cost:
		%Button.disabled = true
		%ManaCostLabel.add_theme_color_override(
			&"font_color", %ManaCostLabel.get_theme_color(&"font_color_disabled")
		)
	else:
		%Button.disabled = false
		%ManaCostLabel.add_theme_color_override(
			&"font_color", %ManaCostLabel.get_theme_color(&"font_color_active")
		)
