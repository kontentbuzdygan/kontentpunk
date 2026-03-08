@tool
extends HBoxContainer

@export var resource_type: PlayerResource.Type
@export var cost: int = 1:
	get:
		return _cost
	set(value):
		_cost = value
		$Label.text = str(_cost)
		update()

@export var icon_enabled: Texture2D
@export var icon_disabled: Texture2D

var _cost: int = 1
var _resource: PlayerResource


func _ready() -> void:
	if not Engine.is_editor_hint():
		_resource = PlayerState.get_resource(resource_type)
		_resource.current_changed.connect(update.unbind(1))
		update()


func update() -> void:
	if _resource:
		if _resource.current < _cost:
			$Icon.texture = icon_disabled
			set_label_color($Label.get_theme_color(&"font_color_disabled"))
		else:
			$Icon.texture = icon_enabled
			set_label_color($Label.get_theme_color(&"font_color_active"))


func set_label_color(color: Color) -> void:
	$Label.add_theme_color_override(&"font_color", color)
