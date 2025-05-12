class_name Movable extends CharacterBody2D

@onready var timer : Timer = $Timer
@onready var audio_emitter : AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var gravity := 300 * 60
@export var y_acc := 5
@export var noise_offset : Vector2

var grabbed := false
var falling := false

func grab() -> void:
	grabbed = true
	velocity = Vector2.ZERO

func release() -> void:
	velocity = Vector2.ZERO
	grabbed = false

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		if grabbed:
			release()
		velocity.y = move_toward(velocity.y, gravity * delta, y_acc)

	move_and_slide()
	if falling && is_on_floor_only():
		Ge.EmitNoise(global_position + noise_offset, 20)
		Ge.play_audio(audio_emitter, 0, "res://Assets/SFX/stone_drop.wav")
	falling = velocity.y != 0
func _process(delta: float) -> void:
	timer.paused = velocity.x == 0
	if !timer.paused && !audio_emitter.playing:
		audio_emitter.play()


func _on_timer_timeout() -> void:
	Ge.EmitNoise(global_position + noise_offset, 20)
