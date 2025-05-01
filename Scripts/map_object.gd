class_name MapObject extends CharacterBody2D

@onready var sprite : AnimatedSprite2D = $Sprite

@export var destructable := false
@export var collidable := false

@export var gravity := 300 * 60
@export var y_acc := 5

var damage_taken := 0

func _ready() -> void:
	if collidable:
		set_collision_layer_value(1, true)
	if destructable:
		set_collision_layer_value(8, true)

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y = move_toward(velocity.y, gravity * delta, y_acc)
	move_and_slide()

func take_damage(damage: int, source) -> void:
	damage_taken = damage_taken + damage
	var frame_count = sprite.sprite_frames.get_frame_count(sprite.animation)
	if damage_taken >= frame_count:
		Ge.play_audio_free(1, "res://Assets/SFX/wood break.mp3")
		queue_free()
	else:
		Ge.play_audio_from_string_array(source.audio_emitter, 1, "res://Assets/SFX/Hit on wood/")
		sprite.frame = damage_taken
