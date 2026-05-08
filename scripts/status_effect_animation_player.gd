class_name StatusEffectAnimationPlayer
extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_animation(animation_name: StringName) -> void:
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
		await animation_player.animation_finished
