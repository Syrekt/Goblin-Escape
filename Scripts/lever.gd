extends Interaction

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

@export var target_door : Node2D

var open := false


func _ready() -> void:
	var save_data = Game.get_singleton().get_data_in_room(name)
	if save_data:
		open = save_data.get("open", open)

	if open:
		sprite.animation = "open"
	else:
		sprite.animation = "closed"

	if target_door:
		sprite.animation_finished.connect(target_door._on_gate_toggled)

func activate() -> void:
	if sprite.is_playing(): return 

	if sprite.frame > 0:
		if sprite.animation == "opening":
			sprite.play("closing")
		elif sprite.animation == "closing":
			sprite.play("opening")
	else:
		if open:
			sprite.play("closing")
		else:
			sprite.play("opening")
	$AudioStreamPlayer2D.play()

	Game.get_singleton().save_data_in_room(name, { "open": sprite.animation == "opening" })

func update(player : Player) -> void:
	if Input.is_action_just_pressed("interact"):
		activate()


func _on_animated_sprite_2d_animation_finished() -> void:
	print("sprite.animation: "+str(sprite.animation));
	open = sprite.animation == "opening"


func _on_interacted() -> void:
	if interaction_speech != "":
		Ge.player.think(interaction_speech)
