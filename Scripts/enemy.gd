class_name Enemy extends CharacterBody2D

const RUN_SPEED = 300.0 * 60

@export var save_list : Array[String]
@export var debug := false

@export var experience_drop := 1

@export var move_speed := 100 * 60
@export var patrol_move_speed := 100 * 60
@export var gravity := 500.0;
@export var slash_damage	:= 1
@export var stab_damage		:= 1
@export var bash_damage		:= 1
@export var in_combat := false
@export var patrolling := false
@export var main_stance : EnemyState
#The one with the assigned values will control the conversation and behavior
@export var chatting := false ##Only one enemy should have this
@export var friend : CharacterBody2D ##Only one enemy should have this
@export var patrol_points : Array[Marker2D]
@export var struggle_state : String
@export var transition_state : String
var current_patrol_point : Marker2D

var patrol_amount := 0

@export var facing := 1
var player_in_range := false
var chase_target : Node2D
var aware := false # Extra awersion, can detect player in dark
var direction_locked := false
var facing_locked := false
var anim_speed := 1.0
var chase_disabled := false
var catched_player := false

var states_locked := false

var counter_attack := false
var dealth_finishing_blow := false

var attack_type_taken : Array[String]

var light_source : Area2D
var ray_light : RayCast2D
var in_shadow := false

signal health_depleted
signal enter_shadow
signal leave_shadow

#This is used to prevent finishing a state when previous states animation finishes in new state
#before it changes the animation
var wait_animation_transition := false 

@onready var animation_player   : AnimationPlayer = $AnimationPlayer
@onready var sprite			    := $Sprite2D
@onready var state_node		    := $StateMachine
@onready var health			    := $Health
@onready var combat_properties  := $CombatProperties
@onready var player_proximity	:= $PlayerProximity
@onready var awareness_timer	: Timer = $AwarenessTimer
@onready var attack_detector	:= $AttackDetector

@onready var cp	= combat_properties
@onready var audio_emitter = $SFX
@onready var emote_emitter = $Emote
@onready var face_location = $FaceMarker
@onready var player : Player

var line_of_sight: RayCast2D

var collectable_scene = preload("res://Objects/collectable.tscn")

var spawn_state : Dictionary

signal heard_noise(id: Enemy)

#region Methods
func set_facing(dir: int):
	if debug: Debugger.printui("dir: "+str(dir))
	dir = sign(dir)
	if dir == 0: return

	facing = dir
	var local_nodes = find_children("*", "Node", true).filter(func(n): return n.is_in_group("Flip"))
	for node in local_nodes:
		if node is Sprite2D:
			node.flip_h = facing == 1
		elif node is Marker2D:
			node.position.x *= -1
		else:
			node.scale.x = facing
func get_movement_dir():
	return sign(velocity.x)
func take_damage(_damage : int, _source: Node2D = null, critical := false):
	if state_node.state.name == "death":
		print("Already dead, don't take damage")
		return

	health.value -= _damage
	aware = true
	if health.value <= 0:
		emit_signal("health_depleted")
	else:
		Ge.play_audio_from_string_array(global_position, 0, "res://SFX/Goblin/Hurt/")
		state_node.state.finished.emit("hurt")
	
	if _source:
		var incoming_dir = sign(_source.global_position.x - global_position.x)
		print("critical: "+str(critical))
		if critical:
			Ge.bleed_gush(global_position, -incoming_dir)
		else:
			Ge.bleed_spurt(global_position, -incoming_dir)

		if _source is Player:
			var attack_type = _source.state_node.state.name
			attack_type_taken.append(attack_type)
			await detect_player(_source)
		if health.value > 0:
			set_facing(incoming_dir)
func next_step_free(direction : int) -> bool:
	if direction == 1:
		var collider = $WallCheckRight.get_collider()
		var colliding = collider && !collider.is_in_group("OneWayColliders")
		return !colliding && $FallCheckRight.is_colliding()
	elif direction == -1:
		var collider = $WallCheckLeft.get_collider()
		var colliding = collider && !collider.is_in_group("OneWayColliders")
		return !colliding && $FallCheckLeft.is_colliding()
	else:
		return true
func move(speed: float, direction: int) -> bool:
	# Returns false if next step isn't free, turning the character or stopping it's movement
	if !next_step_free(direction):
		return false

	velocity.x = speed * direction * get_process_delta_time()

	return velocity.x != 0
func update_animation(anim: String, speed := 1.0, from_end := false) -> void:
	wait_animation_transition = false
	if animation_player.current_animation != anim:
		animation_player.play(&"RESET");
		animation_player.advance(0)
		animation_player.play(anim, -1, speed, from_end)
		animation_player.advance(0)
func hear_noise(noise: Node2D) -> void:
	aware = true
	if !$NoiseIgnoreTimer.is_stopped():
		return

	if noise.source is Player:
		heard_noise.emit(self)
	friend = null
	if !chase_target: match state_node.state.name:
		"idle", "chat_lead":
			state_node.state.finished.emit("triggered")
		"triggered":
			if debug: print("lose target from triggered")
			#Trigger patrol just like losing the target
			lost_target()

	$NoiseIgnoreTimer.start()
func smell(source: Player):
	if !chase_target: match state_node.state.name:
		"idle", "chat_lead", "patrol":
			state_node.state.finished.emit("smell")

func detect_player(target: Player) -> bool:
	var pos = target.global_position
	line_of_sight.target_position = line_of_sight.to_local(pos)
	await get_tree().physics_frame
	if line_of_sight.is_colliding():
		var collider = line_of_sight.get_collider()
		if collider.is_in_group("OneWayColliders"):
			return true
		if chase_target:
			print("line of sight blocked to chase target")
			drop_chase(chase_target)
		return false
	else:
		return true
		
func lost_target() -> void:
	#CHANGES STATE
	if debug: print("lost target")
	emote_emitter.play("confused")
	patrol_amount = 4
	state_node.state.finished.emit("idle")
func save() -> void:
	var save_data = {
		"pos_x" : global_position.x,
		"pos_y" : global_position.y,
		"health" : health.value,
		"state" : state_node.state.name,
		"spawn_state" : spawn_state,
	}
	for i in save_list:
		if get(i):
			save_data[i] = get(i)
		else:
			print("Unkown value on save " + i)
	Ge.save_node(self, save_data)
func load(data: Dictionary) -> void:
	health.value	= data.health
	state_node.state.finished.emit(data.state)

	data.erase("health")
	data.erase("state")

	for key in data.keys():
		set(key, data[key])
func update_patrol_point() -> void:
	var new_point = patrol_points.pick_random()
	while new_point == current_patrol_point:
		new_point = patrol_points.pick_random()
	current_patrol_point = new_point
func start_chase(target:Player) -> void:
	if chase_disabled:
		print("Chase disabled")
		return

	print("start chase")
	player_in_range = true
	chase_target = target
	awareness_timer.stop()
	aware = true
	if target.enemies_on_chase.find(self) == -1:
		target.enemies_on_chase.append(self)
	if !target.combat_target:
		target.combat_target = self
func drop_chase(target:Player) -> void:
	if debug: print("drop chase")
	target.enemies_on_chase.erase(self)
	chase_target = null
	player_in_range = false
	if !awareness_timer.is_inside_tree() || awareness_timer.get_parent() == null:
		add_child(awareness_timer)
	awareness_timer.start()
func assign_player(node:Player) -> void:
	if debug: print("player: "+str(player))
	if debug: print("Assigning player node: " + node.name)
	if debug: print("player: "+str(player))
	player = node
	if !heard_noise.is_connected(player.enemy_heard_noise):
		heard_noise.connect(player.enemy_heard_noise)
func reset() -> void:
	print("Reset: " + name)
	health.value			= health.max_value
	states_locked			= false
	aware					= false
	in_combat				= false
	catched_player			= false
	dealth_finishing_blow	= false
	counter_attack			= false
	attack_type_taken		= []

	global_position.x = spawn_state.pos_x
	global_position.y = spawn_state.pos_y
	set_facing(spawn_state.facing)

	state_node.state.finished.emit("idle")
#endregion
#region Animation end
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if wait_animation_transition: return
	var state = state_node.state
	var state_name = state.name

	match state_name:
		"slash", "stab", "bash":
			state.finished.emit(main_stance.name)
		"hurt":
			var n = randi() % 3
			print("n: "+str(n))
			if n && attack_type_taken.size() > 0:
				var attack_to_counter = attack_type_taken.pick_random()
				print("attack_to_counter: "+str(attack_to_counter))
				match attack_to_counter:
					"slash":
						state.finished.emit("stance_light")
					"stab":
						if get_node_or_null("stance_defensive"):
							state.finished.emit("stance_defensive")
						else:
							state.finished.emit(["stance_light", "stance_heavy"].pick_random())
					"bash", "bash_no_sword":
						state.finished.emit("stance_heavy")
			else:
				state.finished.emit(main_stance.name)
		"laugh":
			if chase_target:
				if chase_target.dead:
					state.finished.emit("leave_player")
				elif chase_target.can_have_sex:
					state.finished.emit("approach_player")
				else:
					state.finished.emit("idle")
			else:
				state.finished.emit("idle")
		"death":
			set_collision_mask_value(1, false)
		"grab":
			if catched_player:
				state.finished.emit(struggle_state)
			else:
				state.finished.emit("stance_light")
		"shoved":
			state.finished.emit("stance_light")
#endregion
#region Node Process
func _ready() -> void:
	line_of_sight = RayCast2D.new()
	line_of_sight.collide_with_bodies = true
	line_of_sight.position = face_location.position
	add_child(line_of_sight)
	$Sprite2D.scale.x = 1
	set_facing(facing)
	if patrol_points.size() > 0:
		current_patrol_point = patrol_points[0]
	#This allows adding patrol points as child objects
	for point in patrol_points:
		var _global_position = point.global_position
		point.get_parent().remove_child(point)
		get_tree().root.add_child.call_deferred(point)
		point.global_position = _global_position

	spawn_state.facing = facing
	spawn_state.pos_x = global_position.x
	spawn_state.pos_y = global_position.y

	enter_shadow.connect(_on_enter_shadow)
	leave_shadow.connect(_on_leave_shadow)
func _process(delta: float) -> void:
	# Check if there is anything that stops the gameplay
	var ui_nodes = get_tree().get_nodes_in_group("UIPanel")
func _physics_process(delta: float) -> void:
	if chase_target:
		await detect_player(player)
	elif player_in_range:
		if player.hiding:
			pass
		elif aware:
			if await detect_player(player):
				if debug: print("Detect player and start chase");
				start_chase(player)
		elif player.invisible:
			pass

	if light_source && light_source.lit:
		ray_light.target_position = ray_light.to_local(light_source.global_position)
		if ray_light.is_colliding():
			if !in_shadow:
				enter_shadow.emit()
		elif in_shadow:
			leave_shadow.emit()
	elif !in_shadow:
			enter_shadow.emit()

	if debug:
		Debugger.printui("State: "+str(state_node.state.name));
		Debugger.printui("player_in_range: "+str(player_in_range))
		Debugger.printui("chase_target: "+str(chase_target))
		Debugger.printui("aware: "+str(aware))
		#Debugger.printui("$WallCheckLeft.is_colliding(): "+str($WallCheckLeft.is_colliding()));
		#Debugger.printui("$WallCheckRight.is_colliding(): "+str($WallCheckRight.is_colliding()));
		#Debugger.printui("$FallCheckLeft.is_colliding(): "+str($FallCheckLeft.is_colliding()));
		#Debugger.printui("$FallCheckRight.is_colliding(): "+str($FallCheckRight.is_colliding()));
		#Debugger.printui("patrolling: "+str(patrolling))
		#Debugger.printui("patrol_amount: "+str(patrol_amount))
		#Debugger.printui("state_node.state.name: "+str(state_node.state.name));
	#region X Movement
	var dir_x = get_movement_dir() if !direction_locked else facing

	if health.value <= 0: cp.pushback_reset()
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
	print("health depleted")
	#state_node.state.call_deferred("emit_signal", "finished", "death")
	state_node.state.finished.emit("death")

	#call_deferred("_spawn_collectable")

func _spawn_collectable() -> void:
	for i in experience_drop:
		# Add exp point to the scene
		var collectable : RigidBody2D = collectable_scene.instantiate()
		collectable.type = collectable.Types.EXPERIENCE
		collectable.amount = 10
		add_child(collectable)

		# Set speed and direction
		var deg = randf_range(-135, -45)
		var rad = deg_to_rad(deg)
		var speed = randf_range(100.0, 300.0)
		collectable.linear_velocity = Vector2.from_angle(rad) * speed
func _on_chase_detector_body_entered(body:Node2D) -> void:
	if debug: print("player body entered in chase detector")
	start_chase(body)
func _on_chase_range_body_exited(body:Player) -> void:
	if debug: print("player body exited chase range")
	drop_chase(body)
func _on_crush_check_body_entered(body:Node2D) -> void:
	if body is Movable && body.velocity.y > 0:
		call_deferred("set_collision_mask_value", 1, false)
		state_node.state.finished.emit("death")
func _on_awareness_timer_timeout() -> void:
	if debug: print("Lost awareness")
	aware = false
func _on_threat_collider_body_entered(body:Node2D) -> void:
	print("threat collider")
	take_damage(health.max_value)
	Ge.play_audio_from_string_array(global_position, 0, "res://SFX/Kalin/Finishers/")
	Ge.bleed_gush(global_position, 1)
func _on_player_proximity_body_entered(body:Player) -> void:
	if !body.hiding:
		if debug: print("Start chase by proximity trigger")
		start_chase(body)
func _on_enter_shadow() -> void:
	in_shadow = true
	var c = Color(0.1, 0.1, 0.1, 0.5)
	create_tween().bind_node(self).tween_property(sprite.material, "shader_parameter/tint_color", c, 0.2)
func _on_leave_shadow() -> void:
	in_shadow = false
	var c = Color(0.0, 0.0, 0.0, 0.0)
	create_tween().bind_node(self).tween_property(sprite.material, "shader_parameter/tint_color", c, 0.2)
#endregion
