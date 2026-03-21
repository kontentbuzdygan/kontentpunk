@tool
extends HBoxContainer

@export var resource_type: PlayerResource.Type
@export var cost: int = 1:
	get:
		return cost
	set(value):
		cost = value
		$Label.text = str(cost)
		update()

@export var icon_enabled: Texture2D
@export var icon_disabled: Texture2D
@export var color_enabled: Color
@export var color_disabled: Color

var _resource: PlayerResource


func _ready() -> void:
	if not Engine.is_editor_hint():
		_resource = PlayerState.get_instance().get_resource(resource_type)
		_resource.current_changed.connect(update.unbind(1))

	update()


func update() -> void:
	var current := _resource.current if _resource else 0

	if current < cost:
		$Icon.texture = icon_disabled
		set_label_color(color_disabled)
	else:
		$Icon.texture = icon_enabled
		set_label_color(color_enabled)


func set_label_color(color: Color) -> void:
	$Label.add_theme_color_override(&"font_color", color)
