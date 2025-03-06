class_name Player extends CharacterBody2D


@export var run_speed := 100.0 * 60.0
@export var walk_speed := 50.0 * 60.0
@export var crouch_speed := 25.0 * 60.0
@export var push_pull_speed := 25.0 * 60.0
@export var slide_speed := 5.0 * 60.0
@export var slide_dec := 7.0
@export var gravity := 500.0
@export var jump_impulse := 200.0
@export var acceleration := 10.0
@export var run_stop_dec := 3.0
@export var bash_stop_dec:= 4.0
@export var climb_xoff := -5
@export var climb_yoff := -13

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
@onready var col_stand_check = $StandCheck
@onready var col_interaction = $Interactor
var movable : Node2D = null


const ingame_menu = preload("res://UI/ingame_menu.tscn")
var open_menu: Node = null

var facing: int = 1

var ignore_corners = false

var interaction_target = null

#const Balloon = preload("res://Dialogues/balloon.tscn")
#
#var dialogue_resource : DialogueResource
#var dialogue_start := "test_scene"

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

func move(delta, facing_locked = false, direction_locked = false):
	var state_name = state_node.state.name
	var dir_x = get_movement_dir() if !direction_locked else facing

	match state_name:
		"crouch_walk":
			velocity.x = move_toward(velocity.x, crouch_speed * dir_x * delta, acceleration)
		"walk", "stance_walk":
			velocity.x = move_toward(velocity.x, walk_speed * dir_x * delta, acceleration)
		"run":
			velocity.x = move_toward(velocity.x, run_speed * dir_x * delta, acceleration)
		"run_stop":
			velocity.x = move_toward(velocity.x, 0, run_stop_dec)
		"bash":
			velocity.x = move_toward(velocity.x, 0, bash_stop_dec)
		"push", "pull":
			Debugger.printui("Push/pull movement");
			velocity.x = move_toward(velocity.x, push_pull_speed * dir_x * delta, acceleration)
		"slide":
			velocity.x = move_toward(velocity.x, 0, slide_dec)

	move_and_slide()
	if(!facing_locked && velocity.x != 0): set_facing(sign(velocity.x))

func fall(delta):
	velocity.y += gravity * delta
	move_and_slide()

func take_damage(_damage):
	print("Player takes damage")
	health.change_by(-_damage)
	state_node.state.finished.emit("hurt")

func check_movable():
	var potential_movable = null
	if(ray_movable.is_colliding): 
		potential_movable = ray_movable.get_collider();

	if(Input.is_action_just_pressed("grab") and potential_movable != null):
		movable = potential_movable
		state_node.state.finished.emit("push_idle")

func check_interactable() -> void:
	if interaction_target != null:
		interaction_target.process()
func can_grab_corner() -> bool:
	return !is_on_floor() && !is_on_ceiling() && !ignore_corners && ray_corner_check.is_colliding() && !ray_corner_prevent.is_colliding()
func can_stand_up() -> bool:
	return !col_stand_check.has_overlapping_bodies()
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
			position.x += 26*facing
			position.y -= 36
			state.finished.emit("idle")
		"slide":
			if can_stand_up():
				state.finished.emit("idle")
				set_crouch_mask(false)
			else:
				state.finished.emit("crouch")
#endregion
#region Node Methods
func _ready() -> void:
	var interaction_prompt = ""
	var events = InputMap.action_get_events("interact")

	if events.size() > 0:

		for event in events:
			print("event: "+str(event))
			if event is InputEventKey:
				print("event.keycode: "+str(event.keycode));
				interaction_prompt = OS.get_keycode_string(event.physical_keycode)
			elif event is InputEventJoypadButton:
				interaction_prompt = "Gamepad Button " + str(event.button_index)
			elif event is InputEventMouseButton:
				interaction_prompt = "Mouse Button " + str(event.button_index)

	print("interaction_prompt: "+str(interaction_prompt))
	$InteractionPrompt.text = interaction_prompt

func _physics_process(delta: float) -> void:
	check_interactable()

func _process(delta: float) -> void:
	Debugger.printui(str(state_node.state.name))
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


func _on_hurtbox_area_entered(area: Area2D) -> void:
	print(area)
#endregion


func _on_interactor_area_entered(area: Area2D) -> void:
	interaction_target = area
	$InteractionPrompt.visible = true


func _on_interactor_area_exited(area: Area2D) -> void:
	if interaction_target == area:
		interaction_target = null
		$InteractionPrompt.visible = false
