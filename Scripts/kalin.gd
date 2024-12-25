class_name Player extends CharacterBody2D

@onready var animation_player := $AnimatedSprite2D

@export var run_speed := 100.0 * 60.0
@export var walk_speed := 50.0 * 60.0
@export var crouch_speed := 25.0 * 60.0
@export var gravity := 500.0
@export var jump_impulse := 200.0
@export var acceleration := 10.0
@export var run_stop_acc := 3.0
@export var bash_stop_acc:= 4.0

@onready var state_node := $StateMachine
@onready var health = $Health

var facing: int = 1

#region Functions
func set_facing(dir := 0):

	facing = dir
	if(facing != 0):
		animation_player.flip_h = facing == -1

func get_movement_dir():
	return Input.get_axis("left", "right")

func move(delta):
	var state_name = state_node.state.name
	var dir_x = get_movement_dir()

	match state_name:
		"crouch_walk":
			velocity.x = move_toward(velocity.x, crouch_speed * dir_x * delta, acceleration)
		"walk", "stance_walk":
			velocity.x = move_toward(velocity.x, walk_speed * dir_x * delta, acceleration)
		"run":
			velocity.x = move_toward(velocity.x, run_speed * dir_x * delta, acceleration)
		"run_stop":
			velocity.x = move_toward(velocity.x, 0, run_stop_acc)
		"bash":
			velocity.x = move_toward(velocity.x, 0, bash_stop_acc)

	move_and_slide()
	if velocity.x != 0: set_facing(sign(velocity.x))

func fall(delta):
	velocity.y += gravity * delta
	move_and_slide()
func take_damage(damage_dealer: Node, damage: int):
	health.change_by(damage)
	state_node.finished.emit("hurt")
#endregion
#region Animation End
func _on_animated_sprite_2d_animation_finished() -> void:
	var state = $StateMachine.state

	match state.name:
		"land":
			state.finished.emit("idle")
		"run_stop":
			var dir_x = get_movement_dir()
			set_facing(dir_x)
			if dir_x == 0:
				state.finished.emit("idle")
			else:
				if Input.is_action_pressed("run"):
					state.finished.emit("run")
				else:
					state.finished.emit("walk")
		"stab", "slash", "bash":
			state.finished.emit("stance_light")
#endregion
func _process(delta: float) -> void:
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
