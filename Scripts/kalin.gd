class_name Player extends CharacterBody2D


@export var run_speed := 100.0 * 60.0
@export var walk_speed := 50.0 * 60.0
@export var crouch_speed := 25.0 * 60.0
@export var gravity := 500.0
@export var jump_impulse := 200.0
@export var acceleration := 10.0
@export var run_stop_acc := 3.0
@export var bash_stop_acc:= 4.0

var damage := 1

@onready var state_node := $StateMachine
@onready var health = $Health
@onready var crouching_mask = $ColliderCrouching
@onready var standing_mask  = $ColliderStanding
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var combat_properties = $CombatProperties

const main_menu = preload("res://Scenes/main_menu.tscn")
var open_menu: Node = null

var facing: int = 1

#region Functions
func set_crouch_mask(value: bool):
	standing_mask.set_disabled(value)
	crouching_mask.set_disabled(!value)

func set_facing(dir: int):
	if dir == 0: return
	facing = dir
	for child in get_children():
		if child is Sprite2D:
			child.flip_h = facing == -1
		elif child is CollisionShape2D or child is Node2D:
			child.scale.x = facing

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
func take_damage(damage):
	print("Player takes damage")
	health.change_by(-damage)
	state_node.state.finished.emit("hurt")
#endregion
#region Animation Ending
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var state = state_node.state

	match state.name:
		"land":
			state.finished.emit("idle")
		"run_stop":
			var dir_x = get_movement_dir()
			if dir_x == 0:
				state.finished.emit("idle")
			else:
				set_facing(dir_x)
				if Input.is_action_pressed("run"):
					state.finished.emit("run")
				else:
					state.finished.emit("walk")
		"stab", "slash", "bash":
			state.finished.emit("stance_light")
		"hurt":
			state.finished.emit("stance_light")
#endregion
func _process(delta: float) -> void:
	Debugger.printui([state_node.state.name])
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("ui_cancel"):
		if open_menu == null:
			open_menu = main_menu.instantiate()
			add_child(open_menu)
		else:
			open_menu.queue_free()
			open_menu = null
		print(open_menu)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	print(area)
