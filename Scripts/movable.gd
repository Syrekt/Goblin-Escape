extends CharacterBody2D

@export var gravity := 300 * 60
@export var y_acc := 5

var grabbed = false

func grab() -> void:
	grabbed = true

func release() -> void:
	velocity = Vector2.ZERO
	grabbed = false


func _physics_process(delta: float) -> void:
	if !is_on_floor():
		if grabbed:
			release()
		velocity.y = move_toward(velocity.y, gravity * delta, y_acc)

	move_and_slide()
