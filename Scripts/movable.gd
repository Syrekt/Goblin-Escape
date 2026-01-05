class_name Movable extends CharacterBody2D

@onready var timer : Timer = $Timer
@onready var drop_emitter : FmodEventEmitter2D = $DropEmitter
@onready var slide_emitter : FmodEventEmitter2D = $SlideEmitter
@onready var collider := $CollisionShape2D
@onready var interaction_prompt : AnimatedSprite2D = $InteractionPrompt

@export var drop_sfx	: String = "res://SFX/stone_drop2.wav"
@export var slide_sfx	: Resource = load("res://SFX/stone_slide1.wav")
@export var gravity		:= 300 * 60
@export var y_acc		:= 5
@export var noise_offset: Vector2
@export var loud_object	:= false

var grabbed := false
var falling := false
var was_moving := false
var is_moving := false
var spawn_fall_protection := true

func grab() -> void:
	grabbed = true
	velocity = Vector2.ZERO
	interaction_prompt._hide()

func release() -> void:
	velocity = Vector2.ZERO
	grabbed = false

func _physics_process(delta: float) -> void:
	collider.one_way_collision = is_on_floor()
	if !is_on_floor():
		if grabbed:
			release()
		velocity.y = move_toward(velocity.y, gravity * delta, y_acc)

	move_and_slide()

	if falling && is_on_floor_only():
		Ge.EmitNoise(self, global_position + noise_offset, 20, loud_object)
		drop_emitter.play()
	falling = velocity.y != 0

	if spawn_fall_protection && is_on_floor():
		spawn_fall_protection = false
func _process(delta: float) -> void:
	is_moving = velocity.x != 0
	if is_moving && !was_moving:
		slide_emitter.play()
	elif !is_moving && was_moving:
		slide_emitter.stop()
	was_moving = is_moving

	timer.paused = !is_moving


func _on_timer_timeout() -> void:
	Ge.EmitNoise(self, global_position + noise_offset, 20, loud_object)

func save() -> Dictionary:
	return {
		"pos_x": global_position.x,
		"pos_y": global_position.y,
	}
func load(data: Dictionary) -> void:
	global_position.x = data.get("pos_x", global_position.x)
	global_position.y = data.get("pos_y", global_position.y)
