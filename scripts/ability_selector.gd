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
		$Button.icon = _ability.icon
		$ManaCostDisplay.cost = _ability.base_mana_cost
	else:
		$Button.icon = null
		$ManaCostDisplay.cost = 0


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var mana := PlayerState.get_resource(PlayerResource.Type.MANA).current

	if mana < _ability.base_mana_cost:
		$Button.disabled = true
	else:
		$Button.disabled = CombatState.is_in_progress()
