class_name Enemy extends CharacterBody2D


const RUN_SPEED = 300.0 * 60

@export var debug := false

@export var move_speed := 100 * 60
@export var patrol_move_speed := 100 * 60
@export var gravity := 500.0;
@export var damage := 1
@export var in_combat := false
@export var patrolling := false
#Only one enemy should have friend and chatting values
#The one with the assigned values will control the conversation and behavior
@export var chatting := false
@export var friend : CharacterBody2D

var patrol_amount := 0

@export var facing := 1
var chase_target : Node2D = null
var direction_locked := false
var facing_locked := false
var anim_speed := 1.0

var states_locked := false

var counter_attack := false

signal health_depleted

@onready var animation_player   = $AnimationPlayer
@onready var sprite			    = $Sprite2D
@onready var state_node		    = $StateMachine
@onready var health			    = $Health
@onready var combat_properties  = $CombatProperties
@onready var player_proximity	= $PlayerProximity

@onready var slash_hitbox = $StateMachine/slash/SlashHitbox/Collider
@onready var stab_hitbox  = $StateMachine/stab/StabHitbox/Collider
@onready var bash_hitbox  = $StateMachine/bash/BashHitbox/Collider
@onready var cp	= combat_properties
@onready var audio_emitter = $SFX
@onready var emote_emitter = $Emote
@onready var face_location = $FaceMarker
@onready var player : Player = get_node("/root/Game/Kalin")

var line_of_sight: RayCast2D = null

signal heard_noise(id: Enemy)

#region Methods
func set_facing(dir: int):
	if dir == 0: pass

	facing = dir
	var local_nodes = find_children("*", "Node", true).filter(func(n): return n.is_in_group("Flip"))
	for node in local_nodes:
		if node is Sprite2D:
			node.flip_h = facing == 1
		else:
			node.scale.x = facing
func get_movement_dir():
	return sign(velocity.x)
func take_damage(_damage : int, _source: Node2D):
	print("Enemy takes damage: "+str(_damage))
	health.value -= _damage
	print("health.value: "+str(health.value));
	if health.value <= 0:
		emit_signal("health_depleted")
	else:
		Ge.play_audio_from_string_array(audio_emitter, 0, "res://Assets/SFX/Goblin/Hurt/")
		state_node.state.finished.emit("hurt")
func next_step_free(direction : int) -> bool:
	if direction == 1:
		return !$WallCheckRight.is_colliding() && $FallCheckRight.is_colliding()
	else:
		return !$WallCheckLeft.is_colliding() && $FallCheckLeft.is_colliding()
func move(speed: float, direction: int) -> bool:
	if !next_step_free(direction):
		return false

	#Update the ray direction towards the direction we want to move
	velocity.x = speed * direction * get_process_delta_time()

	return velocity.x != 0
func update_animation(anim: String, speed := 1.0, from_end := false) -> void:
	if animation_player.current_animation != anim:
		animation_player.play(&"RESET");
		animation_player.advance(0)
		animation_player.play(anim, -1, speed, from_end)
		animation_player.advance(0)
func hear_noise(noise: Node2D) -> void:
	if !$NoiseIgnoreTimer.is_stopped():
		return

	if noise.source is Player:
		heard_noise.emit(self)
	friend = null
	match state_node.state.name:
		"idle", "chat_lead":
			state_node.state.finished.emit("triggered")
		"triggered":
			lost_target()

	$NoiseIgnoreTimer.start()
func target_obstructed(target: CharacterBody2D) -> bool:
	line_of_sight.target_position = line_of_sight.to_local(target.global_position)
	return line_of_sight.is_colliding()
func lost_target() -> void:
	#CHANGES STATE
	print("lost target")
	emote_emitter.play("confused")
	patrol_amount = 4
	state_node.state.finished.emit("idle")
	chase_target = null
#endregion
#region Animation end
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var state = state_node.state
	var state_name = state.name

	match state_name:
		"slash", "stab", "bash":
			state.finished.emit("stance_light")
		"death":
			if is_on_floor():
				set_collision_layer_value(4, false)
				set_collision_mask_value(1, false)
				set_collision_mask_value(2, false)
#endregion
#region Node Process
func _ready() -> void:
	line_of_sight = RayCast2D.new()
	line_of_sight.collide_with_bodies = true
	line_of_sight.position = face_location.position
	add_child(line_of_sight)
	$Sprite2D.scale.x = 1
	set_facing(facing)
	heard_noise.connect(player.enemy_heard_noise)
func _physics_process(delta: float) -> void:
	if debug:
		Debugger.printui("$WallCheckLeft.is_colliding(): "+str($WallCheckLeft.is_colliding()));
		Debugger.printui("$WallCheckRight.is_colliding(): "+str($WallCheckRight.is_colliding()));
		Debugger.printui("$FallCheckLeft.is_colliding(): "+str($FallCheckLeft.is_colliding()));
		Debugger.printui("$FallCheckRight.is_colliding(): "+str($FallCheckRight.is_colliding()));
		Debugger.printui("patrolling: "+str(patrolling))
		Debugger.printui("patrol_amount: "+str(patrol_amount))
		Debugger.printui("state_node.state.name: "+str(state_node.state.name));
	#region X Movement
	var dir_x = get_movement_dir() if !direction_locked else facing

	if cp.pushback_timer > 0:
		velocity.x = lerpf(cp.pushback_vector.x, 0, cp.pushback_elapsed_time / cp.pushback_duration)

		cp.pushback_timer = move_toward(cp.pushback_timer, 0, delta)
		cp.pushback_elapsed_time += delta
		if cp.pushback_timer <= 0: velocity.x = 0
	else:
		cp.pushback_reset()

	#endregion
	#region Y Movement
	if !is_on_floor() && state_node.state.name != "death":
		velocity.y += gravity * delta
	#endregion
	#region Finalize
	floor_max_angle = 1
	move_and_slide()
	if cp.pushback_vector.x != 0:
			set_facing(-sign(cp.pushback_vector.x))
	else:
		if(!facing_locked && velocity.x != 0):
			set_facing(sign(velocity.x))

	#endregion
#endregion
#region Signals
func _on_health_depleted() -> void:
	state_node.state.finished.emit("death")
func _on_chase_detector_body_entered(body:Node2D) -> void:
	if !body.invisible:
		chase_target = body
		if !chase_target.combat_target:
			chase_target.combat_target = self
func _on_chase_detector_body_exited(body:Node2D) -> void:
	if body == chase_target:
		chase_target.combat_target = null
		chase_target = null
func _on_crush_check_body_entered(body:Node2D) -> void:
	if body is Movable:
		call_deferred("set_collision_mask_value", 1, false)
		state_node.state.finished.emit("death")
#endregion
