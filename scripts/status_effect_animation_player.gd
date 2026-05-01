class_name StatusEffectAnimationPlayer
extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

func play_animation(animation_name: StringName) -> void:
	animation_player.play(animation_name)
	await animation_player.animation_finished
