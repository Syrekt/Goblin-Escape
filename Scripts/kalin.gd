class_name Player extends CharacterBody2D


@export var run_speed := 100.0 * 60.0
@export var walk_speed := 50.0 * 60.0
@export var crouch_speed := 25.0 * 60.0
@export var push_pull_speed := 25.0 * 60.0
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
@onready var ray_movable = $MovableCheck
@onready var ray_corner_check = $CornerCheck
@onready var ray_corner_prevent = $CornerPrevent
var movable : Node2D = null


const ingame_menu = preload("res://UI/ingame_menu.tscn")
var open_menu: Node = null

var facing: int = 1

var ignore_corners = false

#const Balloon = preload("res://Dialogues/balloon.tscn")
#
#var dialogue_resource : DialogueResource
#var dialogue_start := "test_scene"

func _ready() -> void:
	print("Starting position : ", position)

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
		elif child is CollisionShape2D or child is Node2D or child is RayCast2D:
			child.scale.x = facing

func get_movement_dir():
	return Input.get_axis("left", "right")

func move(delta):
	var state_name = state_node.state.name
	var dir_x = get_movement_dir()
	var facing_locked = false

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
		"push", "pull":
			facing_locked = true
			Debugger.printui(["Push/pull movement"]);
			velocity.x = move_toward(velocity.x, push_pull_speed * dir_x * delta, acceleration)

	move_and_slide()
	if(!facing_locked && velocity.x != 0): set_facing(sign(velocity.x))

func fall(delta):
	velocity.y += gravity * delta
	move_and_slide()

func take_damage(damage):
	print("Player takes damage")
	health.change_by(-damage)
	state_node.state.finished.emit("hurt")

func check_movable():
	var potential_movable = null
	if(ray_movable.is_colliding): 
		potential_movable = ray_movable.get_collider();

	if(Input.is_action_just_pressed("grab") and potential_movable != null):
		movable = potential_movable
		state_node.state.finished.emit("push_idle")

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
		"corner_climb":
			position.x += 8*facing
			position.y -= 55
			state.finished.emit("idle")
#endregion
#region Node Methods
func _process(delta: float) -> void:
	Debugger.printui([state_node.state.name])
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("ui_cancel"):
		if open_menu == null:
			open_menu = ingame_menu.instantiate()
			add_child(open_menu)
			get_tree().paused = true;
		else:
			get_tree().paused = false;
			open_menu.queue_free()
			open_menu = null
		print(open_menu)

	#if Input.is_action_just_pressed("ui_accept"):
		#print("load dialogue")
		#DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/test.dialogue"), "start")
		#var resource = load("res://Dialogues/test.dialogue")
		#var dialogue_line = await DialogueManager.get_next_dialogue_line(resource, "start")
		#print(dialogue_line)
		#var balloon := Balloon.instantiate()
		#get_tree().current_scene.add_child(balloon)
		#balloon.start(dialogue_resource, dialogue_start)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	print(area)
#endregion
