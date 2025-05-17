extends Node2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	visible = false

func play(anim : String) -> void:
	if !$AnimatedSprite2D.sprite_frames.has_animation(anim):
		print("Animation invalid: " + str($AnimatedSprite2D.sprite_frames.has_animation(anim)))
	sprite.play(anim, 1.0)
	visible = true

func _on_animated_sprite_2d_animation_finished() -> void:
	visible = false
