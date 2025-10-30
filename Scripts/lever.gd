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
	$AudioStreamPlayer2D.play()
func update(player : Player) -> void:
	if Input.is_action_just_pressed("interact"):
		activate()


func _on_animated_sprite_2d_animation_finished() -> void:
	target_door.closed = sprite.animation == "closing"


func _on_interacted() -> void:
	if interaction_speech != "":
		Ge.player.think(interaction_speech)
