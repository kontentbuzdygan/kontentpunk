class_name VerletNode
extends Area2D

@export var gravity_vector: Vector2 = Vector2(0, 9.8)
@export var damping := 0.985
@export var step := 0.05

var pinned: bool = false
var _old_position: Vector2
var _dragging := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_old_position = position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_released("2d_select"):
			_dragging = false


func _physics_process(_delta: float) -> void:
	if _dragging:
		_old_position = position
		position = get_viewport().get_mouse_position()
		return

	if not pinned:
		var temp := position
		position += (position - _old_position) * damping + gravity_vector * step * step
		_old_position = temp


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("2d_select"):
		_dragging = true
	if event.is_action_pressed("2d_dialog"):
		pinned = !pinned
