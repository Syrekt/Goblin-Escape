class_name Player extends CharacterBody2D


@export var run_speed			:= 100.0 * 60.0
@export var walk_speed			:= 50.0 * 60.0
@export var stance_walk_speed	:= 30.0 * 60.0
@export var crouch_speed		:= 30.0 * 60.0
@export var push_pull_speed 	:= 25.0 * 60.0
@export var slide_speed			:= 5.0 * 60.0
@export var slide_dec			:= 7.0
@export var gravity				:= 500.0
@export var jump_impulse		:= 200.0
@export var def_acc				:= 10.0
@export var run_stop_dec		:= 3.0
@export var bash_stop_dec		:= 4.0

@export var snap_offset			:= Vector2(-5, -13)
@export var facing_locked		:= false
@export var direction_locked	:= false
@export var dead				:= false # Health == 0
@export var unconscious			:= false # Post sex situations where health isn't 0

@onready var state_node := $StateMachine
@onready var health : TextureProgressBar = $CanvasLayer/HUD/HBoxContainer/Health
@onready var stamina : TextureProgressBar = $CanvasLayer/HUD/HBoxContainer/Stamina
@onready var crouching_mask : CollisionShape2D = $ColliderCrouching
@onready var standing_mask  : CollisionShape2D = $ColliderStanding
@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var combat_properties = $CombatProperties
@onready var ray_movable : RayCast2D = $MovableCheck
@onready var ray_corner_grab_check : RayCast2D = $CornerGrabCheck
@onready var ray_auto_climb : RayCast2D = $CornerAutoClimb
@onready var col_corner_grab_prevent : Area2D = $CornerGrabPrevent
@onready var col_quick_climb_prevent : Area2D = $QuickClimbPrevent
@onready var col_stand_check : Area2D = $StandCheck
@onready var col_auto_climb_bottom : Area2D = $BottomAutoClimb
@onready var col_interaction : Area2D = $Interactor
@onready var col_corner_hang : Area2D = $CornerHangCheck
@onready var col_corner_climb_prevent : Area2D = $CornerClimbPrevent
@onready var cp = combat_properties
@onready var camera = $Camera2D
@onready var audio_emitter = $MainAudioStreamer

var movable : Node2D = null
var noise = preload("res://Objects/noise.tscn")


const SLASH_COST	:= 2
const STAB_COST		:= 1
const BASH_COST 	:= 2
var slash_damage	:= 2
var stab_damage		:= 1
var bash_damage 	:= 1


const ingame_menu = preload("res://UI/ingame_menu.tscn")
var open_menu : Node = null

var move_speed := 0.0
var facing := 1
var ignore_corners := false
var invisible := false

var interaction_target : Area2D = null

var states_locked := false
var damage := 1

var corner_quick_climb := false

var combat_target : CharacterBody2D = null

var state_on_attack_frame := false

var sex_participants : Array

var last_input_type := "keyboard"


signal health_depleted

#const Balloon = preload("res://Dialogues/balloon.tscn")
#
#var dialogue_resource : DialogueResource
#var dialogue_start := "test_scene"

#region Methods
func set_crouch_mask(value: bool):
	standing_mask.set_disabled(value)
	crouching_mask.set_disabled(!value)

func set_facing(dir: int):
	if dir == 0: return
	facing = dir
	for node in get_tree().get_nodes_in_group("Flip"):
		if node is Sprite2D:
			node.flip_h = facing == -1
		else:
			node.scale.x = facing
func get_movement_dir() -> float:
	if %InventoryPanel.visible: return 0.0
	return Input.get_axis("left", "right")
func fall(delta):
	velocity.y += gravity * delta
	move_and_slide()
func take_damage(_damage: int, _source: Node2D = null, play_hurt_animation := true, attack := {}):
	var state_name = state_node.state.name
	if state_name == "death":
		return
	if state_name == "hiding" || state_name == "hidding" || state_name == "unhide":
		%Sprite2D.material.set_shader_parameter("tint_color", Color(0, 0, 0, 0))

	combat_properties.stunned = false
	var defending = state_node.state.name == "stance_defensive"
	var break_defense = attack.get("break_defense", false)

	if defending && break_defense:
		combat_properties.stun(2.0)
		state_node.state.finished.emit("stunned")
		return

	if defending && !%Stamina.spend(_damage):
		defending = false

	if defending:
		state_node.state.finished.emit("block")
	else:
		health.value -= _damage
		if health.value <= 0:
			emit_signal("health_depleted")
			if _source:
				_source.state_node.state.finished.emit("laugh")
		elif play_hurt_animation:
			state_node.state.finished.emit("hurt")
			Ge.play_audio_from_string_array(audio_emitter, -2, "res://Assets/SFX/Kalin/Hurt")
func heal(amount: int) -> void:
	health.value += amount
func check_movable():
	var potential_movable = null
	if ray_movable.is_colliding(): 
		potential_movable = ray_movable.get_collider();

	if just_pressed("grab") and potential_movable != null:
		movable = potential_movable
		state_node.state.finished.emit("push_idle")

func check_interactable() -> void:
	if interaction_target:
		interaction_target.update(self)
func can_grab_corner(rising := false) -> bool:
	var grab_prevent =  col_corner_grab_prevent.has_overlapping_bodies()
	var grab_trigger = ray_corner_grab_check.is_colliding()

	if col_corner_grab_prevent.has_overlapping_bodies(): return false
	if is_on_floor(): return false
	if is_on_ceiling(): return false
	if ignore_corners: return false
	return true
func can_quick_climb() -> bool:
	return velocity.y < -50.0 && !col_quick_climb_prevent.has_overlapping_bodies() && !col_corner_climb_prevent.has_overlapping_bodies() && ray_auto_climb.is_colliding()
func can_stand_up() -> bool:
	return !col_stand_check.has_overlapping_bodies()
func update_animation(anim: String, speed := 1.0, from_end := false) -> void:
	if animation_player.current_animation != anim:
		animation_player.play(&"RESET");
		animation_player.advance(0)
		animation_player.play(anim, -1, speed, from_end)
		animation_player.advance(0)
		%Sprite2D.material.set_shader_parameter("number_of_images", Vector2(%Sprite2D.hframes, %Sprite2D.vframes))
func snap_to_corner(ledge_position: Vector2) -> void:
	global_position = ledge_position + Vector2(snap_offset.x * facing, snap_offset.y)
func stand_up() -> void:
	state_node.state.finished.emit("idle")
	set_crouch_mask(false)
func quick_climb() -> void:
	corner_quick_climb = true
	state_node.state.finished.emit("corner_climb")
func play_sfx(sfx) -> void:
	audio_emitter.stream = sfx
	audio_emitter.play()
func combat_perform_attack(hitbox: Area2D, _damage: int, whiff_sfx: AudioStreamWAV, hit_sfx: AudioStreamWAV, knockback_force: int) -> void:
	if hitbox.has_overlapping_bodies():
		var body = hitbox.get_overlapping_bodies()[0]
		var was_stunned : bool = body.combat_properties.stunned
		print("was_stunned: "+str(was_stunned))

		var result : int = Combat.deal_damage(self, _damage, body, knockback_force)
		match result:
			Combat.RESULT_STUN:
				Ge.play_audio(audio_emitter, 1, "res://Assets/SFX/Kalin/block_break2.wav")
			Combat.RESULT_WHIFF:
				play_sfx(whiff_sfx)
			Combat.RESULT_HIT:
				play_sfx(hit_sfx)
			Combat.RESULT_BLOCK:
				Ge.play_audio_from_string_array(audio_emitter, 0, "res://Assets/SFX/Sword hit shield")
			Combat.RESULT_DEAD:
				Ge.play_audio_from_string_array(audio_emitter, 0, "res://Assets/SFX/Kalin/Finishers")
	else:
		play_sfx(whiff_sfx)
func sex_begin(participants: Array, _position: String) -> void:
	sex_participants = participants.duplicate()
	print("sex_participants: "+str(sex_participants))
	for participant in sex_participants:
		participant.state_node.state.finished.emit("sex")
	state_node.state.finished.emit("sex")
	call_deferred("update_animation", _position)
func emit_noise(offset : Vector2, amount : float) -> void:
	var _noise = noise.instantiate()
	get_tree().current_scene.add_child(_noise)

	_noise.amount_max = amount
	_noise.position = position + offset
func toggle_inventory():
	%InventoryPanel.toggle()
func pressed(input : String) -> bool:
	if %InventoryPanel.visible: return false
	return Input.is_action_pressed(input)
func just_pressed(input : String) -> bool:
	if %InventoryPanel.visible: return false
	return Input.is_action_just_pressed(input)
func just_released(input : String) -> bool:
	if %InventoryPanel.visible: return false
	return Input.is_action_just_released(input)
func hide_out(hiding_spot : Area2D) -> void:
	global_position = hiding_spot.global_position
	state_node.state.finished.emit("hiding")
#endregion
#region Animation Ending
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var state = state_node.state

	match state.name:
		"land", "land_hurt", "run_stop":
			state.finished.emit("idle")
		"recover":
			state.finished.emit("idle")
			heal(1)
		"stab", "slash", "bash", "block":
			state.finished.emit("stance_light")
		"hurt":
			state.finished.emit("stance_light")
		"corner_climb", "corner_climb_quick":
			state.finished.emit("idle")
		"slide":
			state.finished.emit("crouch")
		"orgasm":
			state_node.state.finished.emit("post_sex")
			for participant in sex_participants:
				participant.state_node.state.finished.emit("leave_player")
		"post_sex":
			state_node.state.finished.emit("recover")
		"corner_hang":
			state_node.state.finished.emit("corner_grab")
		"hiding":
			state_node.state.finished.emit("hidden")
		"unhide":
			state_node.state.finished.emit("idle")
#endregion
#region Init
func _ready() -> void:
	$CanvasLayer.visible = true
	$CanvasLayer/HUD.visible = true
#endregion
#region Physics
func _physics_process(delta: float) -> void:
	#region X Movement
	var state_name = state_node.state.name
	#Don't use input direction for facing if direction_locked
	var dir_x = int(get_movement_dir()) if !direction_locked else facing
	var accelaration = def_acc

	match state_name:
		"idle":
			move_speed = walk_speed * dir_x
		"crouch_walk":
			move_speed = crouch_speed * dir_x
		"walk":
			move_speed = walk_speed * dir_x
		"stance_walk":
			move_speed = stance_walk_speed * dir_x
		"run":
			move_speed = run_speed * dir_x
		"push_idle":
			move_speed = 0
		"push", "pull":
			move_speed = push_pull_speed * dir_x
		"run_stop":
			#Make sure that player can't start moving again if it's stopped by an obstacle in this state
			move_speed = walk_speed * dir_x if velocity.x == 0.0 else 0.0
			accelaration = run_stop_dec
		"bash":
			accelaration = bash_stop_dec
		"slide", "stun":
			accelaration = slide_dec
		"land", "land_hurt":
			move_speed = 0;
			accelaration = slide_dec
		"slash", "stab":
			move_speed = 0;
			accelaration = slide_dec
		"corner_grab", "corner_climb", "corner_hang":
			move_speed = 0
			velocity = Vector2.ZERO
		"hurt":
			velocity.x = 0
			move_speed = 0
			accelaration = slide_dec
		"death", "sex", "recover":
			move_speed = 0
			velocity.x = 0
		"hiding", "hidden", "unhide":
			move_speed = 0
			velocity = Vector2.ZERO


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
			"corner_climb", "corner_grab", "corner_hang":
				velocity.y = 0
			_:
				velocity.y += gravity * delta

	#endregion
	#region Finalize
	floor_max_angle = 1
	move_and_slide()
	if cp.pushback_timer > 0:
			set_facing(-sign(cp.pushback_vector.x))
	else:
		if(!facing_locked && velocity.x != 0):
			set_facing(sign(velocity.x))

	#endregion
#endregion
#region Process
func _process(delta: float) -> void:
	var s = %Sprite2D
	Debugger.printui(str(state_node.state.name))
	Debugger.printui("$Interactor.has_overlapping_areas(): "+str($Interactor.has_overlapping_bodies()));
	if ray_auto_climb.is_colliding():
		var collider = ray_auto_climb.get_collider()
	#region Camera combat position
	var in_combat_state = state_node.state.is_in_group("combat_state")
	if in_combat_state && combat_target:
		camera.position.x = (combat_target.global_position.x - global_position.x)/2;
		if combat_target.state_node.state.name == "death": combat_target = null
	else:
		camera.position.x = 0
	#endregion
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	#region Open menu & Inventory
	if Input.is_action_just_pressed("ui_cancel"):
		if open_menu == null:
			open_menu = ingame_menu.instantiate()
			add_child(open_menu)
			get_tree().paused = true;
		else:
			get_tree().paused = false;
			open_menu.queue_free()
			open_menu = null
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()

	#endregion
	if Input.is_action_just_pressed("debug1"):
		print("debug1")
		take_damage(4)
		#if randi_range(0, 1) == 1:
		#	%InventoryPanel.pickup_item(load("res://Inventory/water.tres"))
		#else:
		#	%InventoryPanel.pickup_item(load("res://Inventory/health_potion.tres"))

	check_interactable()
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		last_input_type = "gamepad"
	elif event is InputEventKey || event is InputEventMouse:
		last_input_type = "keyboard"
#endregion
#region Signals
func _on_hurtbox_area_entered(area: Area2D) -> void:
	print(area)
func _on_interactor_area_entered(area: Area2D) -> void:
	print("interactor area entered")
	interaction_target = area
	$InteractionPrompt._show(last_input_type)
func _on_interactor_area_exited(area: Area2D) -> void:
	print("interactor area exited")
	if interaction_target == area:
		interaction_target.waiting_player_exit = false
		interaction_target = null
		$InteractionPrompt._hide()
func _on_health_depleted() -> void:
	state_node.state.finished.emit("death")
#endregion
