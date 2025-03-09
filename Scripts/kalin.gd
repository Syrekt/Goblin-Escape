class_name Player extends CharacterBody2D


@export var run_speed := 100.0 * 60.0
@export var walk_speed := 50.0 * 60.0
@export var crouch_speed := 25.0 * 60.0
@export var push_pull_speed := 25.0 * 60.0
@export var slide_speed := 5.0 * 60.0
@export var slide_dec := 7.0
@export var gravity := 500.0
@export var jump_impulse := 200.0
@export var def_acc := 10.0
@export var run_stop_dec := 3.0
@export var bash_stop_dec:= 4.0
@export var snap_offset := Vector2(-5, -13)
@export var facing_locked		:= false
@export var direction_locked	:= false


@onready var state_node := $StateMachine
@onready var health = $CanvasLayer/Control/HBoxContainer/Health
@onready var stamina = $CanvasLayer/Control/HBoxContainer/Stamina
@onready var crouching_mask = $ColliderCrouching
@onready var standing_mask  = $ColliderStanding
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var combat_properties = $CombatProperties
@onready var ray_movable = $MovableCheck
@onready var ray_corner_grab_check = $CornerGrabCheck
@onready var ray_auto_climb = $CornerAutoClimb
@onready var col_corner_grab_prevent = $CornerGrabPrevent
@onready var col_stand_check = $StandCheck
@onready var col_interaction = $Interactor
@onready var cp = combat_properties
@onready var camera = $Camera2D
var movable : Node2D = null


const SLASH_COST = 2
const STAB_COST = 1
const BASH_COST = 2


const ingame_menu = preload("res://UI/ingame_menu.tscn")
var open_menu: Node = null

var move_speed := 0.0
var facing := 1
var ignore_corners = false

var interaction_target = null

var states_locked := false
var damage := 1

var corner_quick_climb := false

signal health_depleted

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



func fall(delta):
	velocity.y += gravity * delta
	move_and_slide()

func take_damage(_damage):
	if state_node.state.name == "death":
		return

	print("Player takes damage: " + str(_damage))
	health.value -= damage
	if health.value <= 0:
		emit_signal("health_depleted")
	else:
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
func can_grab_corner(rising:= false) -> bool:
	var grab_prevent =  col_corner_grab_prevent.has_overlapping_bodies()
	var grab_trigger = ray_corner_grab_check.is_colliding()



	if col_corner_grab_prevent.has_overlapping_bodies(): return false
	if is_on_floor(): return false
	if is_on_ceiling(): return false
	if ignore_corners: return false
	return true
func can_stand_up() -> bool:
	return !col_stand_check.has_overlapping_bodies()
func update_animation(anim: String, speed := 1.0, from_end := false) -> void:
	if animation_player.current_animation != anim:
		animation_player.play(&"RESET");
		animation_player.advance(0)
		print("speed: "+str(speed))
		print("from_end: "+str(from_end))
		animation_player.play(anim, -1, speed, from_end)
		animation_player.advance(0)
func snap_to_corner(ledge_position: Vector2) -> void:
	global_position = ledge_position + Vector2(snap_offset.x * facing, snap_offset.y)
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
		"corner_climb", "corner_climb_quick":
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
	$CanvasLayer.visible = true
	var interaction_prompt = ""
	var events = InputMap.action_get_events("interact")

	if events.size() > 0:

		for event in events:
			if event is InputEventKey:
				interaction_prompt = OS.get_keycode_string(event.physical_keycode)
			elif event is InputEventJoypadButton:
				interaction_prompt = "Gamepad Button " + str(event.button_index)
			elif event is InputEventMouseButton:
				interaction_prompt = "Mouse Button " + str(event.button_index)

	$InteractionPrompt.text = interaction_prompt

func _physics_process(delta: float) -> void:
	#region X Movement
	var state_name = state_node.state.name
	var dir_x = int(get_movement_dir()) if !direction_locked else facing
	var accelaration = def_acc

	match state_name:
		"idle":
			move_speed = 0
		"crouch_walk":
			move_speed = crouch_speed * dir_x
		"walk", "stance_walk":
			move_speed = walk_speed * dir_x
		"run":
			move_speed = run_speed * dir_x
		"push", "pull":
			move_speed = push_pull_speed * dir_x
		"run_stop":
			move_speed = walk_speed * dir_x
			accelaration = run_stop_dec
		"bash":
			accelaration = bash_stop_dec
		"slide", "stun":
			accelaration = slide_dec
		"land":
			move_speed = 0;
			accelaration = slide_dec
		"slash", "stab":
			move_speed = 0;
			accelaration = slide_dec
		"corner_grab", "corner_climb":
			move_speed = 0
			velocity.x = 0
			velocity.y = 0
		"hurt":
			move_speed = 0
			accelaration = slide_dec
		"death":
			move_speed = 0
			velocity.x = 0


	if cp.pushback_timer > 0:
		velocity.x = lerpf(cp.pushback_vector.x, 0, cp.pushback_elapsed_time / cp.pushback_duration)

		cp.pushback_timer = move_toward(cp.pushback_timer, 0, delta)
		cp.pushback_elapsed_time += delta
		if cp.pushback_timer <= 0: velocity.x = 0
	else:
		velocity.x = move_toward(velocity.x, move_speed * delta, accelaration)
		cp.pushback_reset()

	#endregion
	#region Y Movement
	if !is_on_floor():
		match state_name:
			"corner_climb", "corner_grab":
				velocity.y = 0
			_:
				velocity.y += gravity * delta

	#endregion
	#region Finalize
	move_and_slide()
	if cp.pushback_timer > 0:
			set_facing(-sign(cp.pushback_vector.x))
	else:
		if(!facing_locked && velocity.x != 0):
			set_facing(sign(velocity.x))

	check_interactable()

	#endregion

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

	if Input.is_action_just_pressed("debug1"):
		print("Stun")
		get_node("/root/Game/Enemy").cp.stun()


#endregion
#region Signals
func _on_hurtbox_area_entered(area: Area2D) -> void:
	print(area)
func _on_interactor_area_entered(area: Area2D) -> void:
	interaction_target = area
	$InteractionPrompt.visible = true


func _on_interactor_area_exited(area: Area2D) -> void:
	if interaction_target == area:
		interaction_target = null
		$InteractionPrompt.visible = false
func _on_health_depleted() -> void:
	state_node.state.finished.emit("death")
#endregion
