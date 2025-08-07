extends Interaction

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

@export var target_door : Node2D


func _ready() -> void:
	sprite.play("opening")
	sprite.stop()

func activate() -> void:
	if sprite.is_playing(): return 

	print("sprite.animation: "+str(sprite.animation));
	if sprite.frame > 0:
		if sprite.animation == "opening":
			sprite.play("closing")
		elif sprite.animation == "closing":
			sprite.play("opening")
	else:
		sprite.play()
func update(player : Player) -> void:
	if auto:
		if !active && !waiting_player_exit:
			waiting_player_exit = true
			activate()
	else:
		if !active && Input.is_action_just_pressed("interact"):
			activate()



func _on_animated_sprite_2d_animation_finished() -> void:
	target_door.closed = sprite.animation == "closing"
