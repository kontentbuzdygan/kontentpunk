extends VBoxContainer

@export var digit_flip_interval: float = 0.02
@export var changing_font_color: Color

@onready var money: PlayerResource = PlayerState.get_instance().money

var _value: int
var _t: float = 0.0


func _ready() -> void:
	_value = money.current
	$Label.text = str(_value)


func _process(delta: float) -> void:
	_t += delta
	while _t >= digit_flip_interval:
		_t -= digit_flip_interval

		if money.current != _value:
			_value += sign(money.current - _value)
			$Label.text = str(_value)
			$Label.add_theme_color_override(&"font_color", changing_font_color)
		else:
			$Label.remove_theme_color_override(&"font_color")
