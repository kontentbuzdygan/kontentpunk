@tool
class_name AbilitySelector
extends VBoxContainer

@export var ability: Ability:
	get:
		return ability
	set(value):
		if ability == value:
			return

		if ability and ability.changed.is_connected(update_children):
			ability.changed.disconnect(update_children)

		ability = value

		if ability:
			ability.changed.connect(update_children)

		update_children()


func _ready() -> void:
	if not Engine.is_editor_hint():
		PlayerState.mana.current_changed.connect(update_children.unbind(1))


func update_children() -> void:
	if ability:
		$Button.icon = ability.icon
		$Button.tooltip_text = ability.name
		$ManaCostDisplay.cost = ability.base_mana_cost
	else:
		$Button.icon = null
		$ManaCostDisplay.cost = 0


func set_index(index: int) -> void:
	var shortcut := Shortcut.new()
	var shortcut_event := InputEventKey.new()
	shortcut_event.keycode = (KEY_1 + index) as Key
	shortcut.events = [shortcut_event]
	$Button.shortcut = shortcut
	$Button/ShortcutLabel.text = shortcut.get_as_text()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	## TODO: after changing PlayerState to autoload
	## the type of mana can't be inferred?
	var mana: int = PlayerState.mana.current

	if mana < ability.base_mana_cost:
		$Button.disabled = true
	else:
		$Button.disabled = CombatState.get_instance().is_in_progress()
