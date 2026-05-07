@tool
extends HBoxContainer

@export var resource_type: ActorResource.Type
@export var cost: int = 1:
	get:
		return cost
	set(value):
		cost = value
		$Label.text = str(cost)
		update()

@export var icon_enabled: Texture2D
@export var icon_disabled: Texture2D
@export var label_type_variation: StringName:
	get:
		return label_type_variation
	set(value):
		label_type_variation = value
		if is_node_ready():
			$Label.theme_type_variation = label_type_variation

var _resource: ActorResource


func _ready() -> void:
	$Label.theme_type_variation = label_type_variation

	if not Engine.is_editor_hint():
		_resource = PlayerState.get_instance().get_resource(resource_type)
		_resource.current_changed.connect(update.unbind(1))

	update()


func update() -> void:
	var current := _resource.current if _resource else 0

	if current < cost:
		$Icon.texture = icon_disabled
		set_label_color(&"font_color_disabled")
	else:
		$Icon.texture = icon_enabled
		set_label_color(&"font_color_active")


func set_label_color(color_name: StringName) -> void:
	$Label.add_theme_color_override(&"font_color", $Label.get_theme_color(color_name))
