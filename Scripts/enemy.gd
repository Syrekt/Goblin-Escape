class_name Enemy extends CharacterBody2D


const RUN_SPEED = 300.0 * 60

@export var move_speed := 100 * 60
@export var patrol_move_speed := 100 * 60
@export var gravity := 500.0;
@export var damage := 1

var facing := 1
var chase_target : Node2D
var direction_locked := false
var facing_locked := false

var states_locked := false

var push_player := false

signal health_depleted

@onready var animation_player   = $AnimationPlayer
@onready var sprite			    = $Sprite2D
@onready var state_node		    = $StateMachine
@onready var health			    = $Health
@onready var combat_properties  = $CombatProperties
@onready var ray_fall_check		= $FallCheck
@onready var state_switch_timer = $StateSwitchTimer
@onready var player_proximity = $PlayerProximity

@onready var slash_hitbox = $StateMachine/slash/SlashHitbox/Collider
@onready var stab_hitbox  = $StateMachine/stab/StabHitbox/Collider
@onready var bash_hitbox  = $StateMachine/bash/BashHitbox/Collider
@onready var cp	= combat_properties

var line_of_sight: RayCast2D = null

func _ready() -> void:
	line_of_sight = RayCast2D.new()
	add_child(line_of_sight)
	$Sprite2D.scale.x = 1

func set_facing(dir: int):
	if dir == 0: pass

	facing = dir
	for node in get_tree().get_nodes_in_group("Flip"):
		if node is Sprite2D:
			node.flip_h = facing == 1
		else:
			node.scale.x = facing

func get_movement_dir():
	return sign(velocity.x)


func take_damage(_damage):
	print("Enemy takes damage: "+str(_damage))
	health.value -= _damage
	print("health.value: "+str(health.value));
	if health.value <= 0:
		emit_signal("health_depleted")
	else:
		state_node.state.finished.emit("hurt")


func move(speed: float, direction: int) -> bool:
	#Update the ray direction towards the direction we want to move
	ray_fall_check.scale.x = direction

	velocity.x = speed * direction * get_process_delta_time()
	return !is_on_wall() && ray_fall_check.is_colliding() && velocity.x != 0
func update_animation(anim: String) -> void:
	animation_player.play(&"RESET");
	animation_player.advance(0)
	animation_player.play(anim)
	animation_player.advance(0)
func _physics_process(delta: float) -> void:
	if player_proximity.has_overlapping_bodies():
		Debugger.printui("Overlapping player")
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
	move_and_slide()
	if cp.pushback_vector.x != 0:
			set_facing(-sign(cp.pushback_vector.x))
	else:
		if(!facing_locked && velocity.x != 0):
			set_facing(sign(velocity.x))

	#endregion

func _on_health_depleted() -> void:
	state_node.state.finished.emit("death")


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


func _on_slash_hitbox_body_entered(body: Node2D) -> void:
	Combat.deal_damage(self, body, 50.0)

func _on_stab_hitbox_body_entered(body: Node2D) -> void:
	Combat.deal_damage(self, body, 50.0)

func _on_bash_hitbox_body_entered(body: Node2D) -> void:
	Combat.deal_damage(self, body, 100.0)
