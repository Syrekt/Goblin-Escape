class_name Enemy extends CharacterBody2D


const RUN_SPEED = 300.0 * 60

@export var move_speed := 100 * 60
@export var gravity := 500.0;
@export var damage := 1

var facing := 1
var chase_target : Node2D

@onready var animation_player   = $AnimationPlayer
@onready var sprite			    = $Sprite2D
@onready var state_node		    = $StateMachine
@onready var health			    = $Health
@onready var combat_properties  = $CombatProperties
@onready var ray_fall_check		= $FallCheck
@onready var state_switch_timer = $StateSwitchTimer

@onready var slash_hitbox = $StateMachine/slash/SlashHitbox/Collider
@onready var stab_hitbox  = $StateMachine/stab/StabHitbox/Collider
@onready var bash_hitbox  = $StateMachine/bash/BashHitbox/Collider

var line_of_sight: RayCast2D

func _ready() -> void:
	line_of_sight = RayCast2D.new()
	add_child(line_of_sight)
	$Sprite2D.scale.x = 1

func set_facing(dir: int):
	if dir == 0: pass

	facing = dir
	for child in get_children():
		if child is Sprite2D:
			child.flip_h = facing == 1
		elif child is CollisionShape2D || child is Node2D || child is RayCast2D:
			child.scale.x = facing

func move(dir: int, delta: float) -> bool:
	if dir == 0:
		animation_player.play("idle")
		return false
	velocity.x = dir * move_speed * delta

	move_and_slide()

	if is_on_wall() || !ray_fall_check.is_colliding():
		velocity.x = 0;

	if velocity.x == 0:
		animation_player.play("idle")
	else:
		set_facing(sign(velocity.x))
		animation_player.play("run")

	return velocity.x != 0


func get_movement_dir():
	return sign(velocity.x)


func take_damage(_damage):
	print("Enemy takes damage")
	health.change_by(-_damage)
	state_node.state.finished.emit("hurt")


func _process(delta):
	Debugger.printui("Enemy state: " + str(state_node.state.name))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if combat_properties.pushback_timer > 0:
		combat_properties.pushback_timer = move_toward(combat_properties.pushback_timer, 0, delta)
		combat_properties.pushback_elapsed_time += delta
		Debugger.printui(str(combat_properties.pushback_vector))
		velocity = combat_properties.pushback_vector.lerp(Vector2.ZERO, combat_properties.pushback_elapsed_time / combat_properties.pushback_duration)
		if combat_properties.pushback_timer <= 0: velocity = Vector2.ZERO
	else:
		combat_properties.pushback_elapsed_time = 0.0

func _on_health_health_depleted() -> void:
	state_node.state.finished.emit("death")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var state = state_node.state
	var state_name = state.name

	match state_name:
		"slash", "stab", "bash":
			state.finished.emit("stance_light")


func _on_slash_hitbox_body_entered(body: Node2D) -> void:
	Combat.deal_damage(self, body, 50)

func _on_stab_hitbox_body_entered(body: Node2D) -> void:
	Combat.deal_damage(self, body, 50)

func _on_bash_hitbox_body_entered(body: Node2D) -> void:
	Combat.deal_damage(self, body, 100)
