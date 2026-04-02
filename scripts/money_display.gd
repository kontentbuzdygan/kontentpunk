extends VBoxContainer

@export var digit_flip_interval: float = 0.02
@export var decreasing_font_color: Color
@export var increasing_font_color: Color

@onready var money: PlayerResource = PlayerState.get_instance().money

var _value: int
var _t: float = 0.0
var _normal_font_color: Color


func _ready() -> void:
	_value = money.current
	$Label.text = str(_value)
	_normal_font_color = $Label.get_theme_color(&"font_color")


func _process(delta: float) -> void:
	_t += delta
	while _t >= digit_flip_interval:
		_t -= digit_flip_interval

		if money.current != _value:
			var difference: int = sign(money.current - _value)

			_value += difference
			$Label.text = str(_value)

			if difference < 0:
				$Label.add_theme_color_override(&"font_color", decreasing_font_color)
			elif difference > 0:
				$Label.add_theme_color_override(&"font_color", increasing_font_color)
		else:
			$Label.add_theme_color_override(&"font_color", _normal_font_color)
