class_name Movable extends CharacterBody2D

@onready var timer : Timer = $Timer
@onready var audio_emitter : AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var drop_sfx : String = "res://SFX/stone_drop2.wav"
@export var slide_sfx : Resource = load("res://SFX/stone_slide1.wav")
@export var gravity := 300 * 60
@export var y_acc := 5
@export var noise_offset : Vector2

var grabbed := false
var falling := false
var was_moving := false
var spawn_fall_protection := true

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
		if spawn_fall_protection:
			spawn_fall_protection = false
		else:
			Ge.EmitNoise(self, global_position + noise_offset, 20)
			Ge.play_audio(audio_emitter, 0, drop_sfx)
	falling = velocity.y != 0
func _process(delta: float) -> void:
	var is_moving = velocity.x != 0
	if is_moving && !was_moving:
		if !audio_emitter.playing:
			audio_emitter.stream = slide_sfx
			audio_emitter.play()
	elif !is_moving && was_moving:
		print("Stop audio")
		audio_emitter.stop()
	was_moving = is_moving

	timer.paused = !is_moving


func _on_timer_timeout() -> void:
	Ge.EmitNoise(self, global_position + noise_offset, 20)
