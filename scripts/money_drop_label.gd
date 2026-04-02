class_name MoneyDropLabel
extends Control

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_animation(money_drop: int) -> void:
	label.text = "+%d" % money_drop
	animation_player.play(&"appear")
	await animation_player.animation_finished
