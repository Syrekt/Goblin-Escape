class_name Enemy extends CharacterBody2D

@export var save_list : Array[String]
@export var debug := false
@export var map_icon : String
var draw_on_map := true

@export var experience_drop := 1

var move_speed	:= 0.0
var force_x		:= 0.0
var force_tween : Tween
var last_ground_y := 0.0
@export var chase_move_speed	:= 100
@export var patrol_move_speed	:= 75
@export var combat_move_speed	:= 50
@export var stab_step_speed 	:= 100
@export var slash_step_speed 	:= 200
@export var lunge_speed			:= 50
@export var gravity := 500.0;
@export var slash_damage	:= 1
@export var stab_damage		:= 1
@export var bash_damage		:= 1
@export var in_combat := false
@export var patrolling := true
@export var main_stance : EnemyState
#The one with the assigned values will control the conversation and behavior
@export var chatting := false ##Only one enemy should have this
@export var friend : CharacterBody2D ##Only one enemy should have this
@export var patrol_points : Array[Marker2D]
@export var struggle_state : String
@export var transition_state : String
var current_patrol_point : Marker2D

var patrol_amount := 0

@export_enum("Left:-1", "Right:1") var facing : int = -1
var player_in_range := false
var chase_target : Player
var target_in_sight := false
var aware := false # Extra awersion, can detect player in dark
var direction_locked := false
var facing_locked := false
var anim_speed := 1.0
var chase_disabled := false ## Disabled in struggle state
var catched_player := false

var states_locked	:= false
var is_dead			:= false

var counter_attack := false
var dealth_finishing_blow := false

var attack_type_taken : Array[String]
@export var stun_state := "stun"

var light_source : Area2D
var ray_light : RayCast2D
var in_shadow := false

signal health_depleted
signal enter_shadow
signal leave_shadow

#This is used to prevent finishing a state when previous states animation finishes in new state
#before it changes the animation
var wait_animation_transition := false 

@onready var animation_player		: AnimationPlayer = $AnimationPlayer
@onready var sprite			    	:= $Sprite2D
@onready var state_node		    	:= $StateMachine
@onready var health			    	:= $EnemyHealth
@onready var combat_properties  	:= $CombatProperties
@onready var player_proximity		:= $PlayerProximity
@onready var awareness_timer		: Timer = $AwarenessTimer
@onready var attack_detector		:= $AttackDetector
@onready var enemy_proximity		: Area2D = $EnemyProximity
@onready var chase_detector			: Area2D = $ChaseDetector
@onready var destructable_detector	: Area2D = $DestructableCollider

@onready var cp	= combat_properties
@onready var sfx_emitter : FmodEventEmitter2D = $SFXEmitter
@onready var emote_emitter = $Emote
@onready var face_location = $FaceMarker
@onready var player : Player

var line_of_sight: RayCast2D

var collectable_scene = preload("res://Objects/collectable.tscn")

var spawn_state : Dictionary

signal heard_noise(id: Enemy) ## Triggers Kalin's reaction

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
func enviroment_kill(anim:String) -> void:
	stop_force_x()
	health.value = 0
	sfx_emitter.set_parameter("EnemySound", "SpikeDeath")
	sfx_emitter.play()

	Ge.bleed_gush(global_position, 1)
	state_node.state.finished.emit("death", {"animation": anim})
func take_damage(_damage : int, _source: Node2D = null, critical := false):
	stop_force_x()
	if state_node.state.name == "death":
		print("Already dead, don't take damage")
		return

	health.value -= _damage
	print("health.value: "+str(health.value));
	if health.value <= 0:
		emit_signal("health_depleted")
	else:
		sfx_emitter.set_parameter("EnemySound", "Hurt")
		sfx_emitter.play()
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
			aware = true
			assign_chase_target(_source)
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
func move(speed: float, direction: int, look_towards := direction) -> bool:
	# Returns false if next step isn't free, turning the character or stopping it's movement

	if look_towards != 0:
		set_facing(look_towards)
	if next_step_free(direction):
		move_speed = speed * direction
		return true
	else:
		move_speed = 0
		return false
func apply_force_x(force, life, _ease = Tween.EASE_OUT) -> void:
	if force_tween && force_tween.is_valid():
		force_tween.kill()

	force_tween = create_tween().bind_node(self).set_ease(_ease)
	force_x = force * facing
	force_tween.tween_property(self, "force_x", 0.0, life)
func stop_force_x() -> void: ## Stops the force_x and kills tween
	if force_tween && force_tween.is_valid():
		force_tween.kill()
	force_x = 0
func update_animation(anim: String, speed := 1.0, from_end := false) -> void:
	wait_animation_transition = false
	if animation_player.current_animation != anim:
		animation_player.play(&"RESET");
		animation_player.advance(0)
		animation_player.play(anim, -1, speed, from_end)
		animation_player.advance(0)
func hear_noise(noise: Node2D) -> void:
	if !noise.loud:
		var ray = RayCast2D.new()
		add_child(ray)
		var pos = noise.global_position
		pos.y -= 10
		ray.target_position = ray.to_local(pos)
		ray.force_raycast_update()
		var collider = ray.get_collider()
		if collider && collider is CollisionObject2D:
			var owner_id = collider.get_shape_owners()[0]
			if collider.is_shape_owner_one_way_collision_enabled(owner_id):
				ray.add_exception(collider)
		if ray.is_colliding():
			if debug: print("Raycast blocked, can't hear player")
			ray.queue_free()
			return
		ray.queue_free()

	aware = true
	if !$NoiseIgnoreTimer.is_stopped():
		return

	print("noise.source: "+str(noise.source));
	if !chase_target && noise.source is Player:
		if state_node.state.name == "patrol":
			state_node.state.hear_noise.emit(noise)
		print("noise.global_position: "+str(noise.global_position));
		var dir = sign(noise.global_position.x - global_position.x)
		set_facing(noise.global_position.x  - global_position.x)
		emote_emitter.play("triggered")
		heard_noise.emit(self)
	friend = null
	if !chase_target: match state_node.state.name:
		"idle", "chat_lead":
			state_node.state.finished.emit("triggered")
			emote_emitter.play("triggered")
		"triggered":
			if debug: print("lose target from triggered")
			#Trigger patrol just like losing the target
			lost_target()

	$NoiseIgnoreTimer.start()
func smell(source: Player):
	if !chase_target: match state_node.state.name:
		"idle", "chat_lead", "patrol":
			set_facing(source.global_position.x  - global_position.x)
			state_node.state.finished.emit("smell")

func lost_target() -> void:
	#CHANGES STATE
	print("lost target")
	emote_emitter.play("confused")
	patrol_amount = 4
	state_node.state.finished.emit("idle")
func save() -> Dictionary:
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
	return save_data
func load_data(data: Dictionary) -> void:
	health.value	= data.health
	state_node.state.finished.emit(data.state, {"loading":true})

	data.erase("health")
	data.erase("state")

	for key in data.keys():
		set(key, data[key])
	global_position = Vector2(data.pos_x, data.pos_y)
func update_patrol_point() -> void:
	var new_point = patrol_points.pick_random()
	while new_point == current_patrol_point:
		new_point = patrol_points.pick_random()
	current_patrol_point = new_point
func player_detected() -> bool:
	if !target_in_sight: return false
	if chase_target.hiding: return false
	if !aware && chase_target.invisible: return false

	if debug: print("Detect player");
	return true
func start_chase() -> void:
	if chase_disabled:
		if debug: print("Chase disabled")
		return
	if chase_target && !target_in_sight:
		if debug: print("No line of sight")
		return

	if !chase_target && !aware:
		emote_emitter.play("alarmed")
	player_in_range = true
	print("Set aware from start_chase")
	aware = true
	awareness_timer.stop()
	if chase_target.enemies_on_chase.find(self) == -1:
		chase_target.enemies_on_chase.append(self)
	if !chase_target.combat_target:
		chase_target.combat_target = self
	state_node.state.finished.emit("chase")
func drop_chase() -> void:
	if debug: print("drop chase")
	if chase_target:
		chase_target.enemies_on_chase.erase(self)
	drop_chase_target()
	player_in_range = false
	awareness_timer.call_deferred("start")
func assign_chase_target(target) -> void:
	chase_target = target
	if !chase_target.combat_target:
		chase_target.combat_target = self
func drop_chase_target() -> void:
	if chase_target:
		if chase_target.combat_target == self:
			chase_target.combat_target = null
	chase_target = null
	if debug: print("Drop chase target")
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
func has_enemy_in_proximity() -> bool:
	if enemy_proximity.get_overlapping_bodies().any(func(b): return b != self):
		return true
	return false
func pick_attack_state(state_array: Array, target: Player) -> String:
	print("State name: "+str(state_node.state.name));
	print("state_array: "+str(state_array))
	var state = state_array.pick_random().name
	print("state: "+str(state))
	while state == "grab" && (!target.can_be_grabbed || get_floor_angle() != 0) :
		if !target.can_be_grabbed: print("Target can't be grabbed")
		if get_floor_angle() != 0: print("Can't grab, not on flat floor")
		state = state_array.pick_random().name
	print("Returning attack state %s" %state)
	return state
func play_chatter_emote() -> void:
	var frames = emote_emitter.sprite.sprite_frames
	var animation_names = frames.get_animation_names()
	var emote = animation_names[randi() % animation_names.size()]
	emote_emitter.play(emote)
func should_step_on_attack() -> bool:
	return position.distance_to(chase_target.position) > 48
#endregion
#region Animation end
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if wait_animation_transition: return
	var state = state_node.state
	var state_name = state.name
	if debug:
		print("anim_name: "+str(anim_name))

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
						if get_node_or_null("StateMachine/stance_defensive"):
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
	set_floor_snap_length(12.0)
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

	awareness_timer.stop()

	chase_detector.body_entered.connect(_on_chase_detector_body_entered)
	chase_detector.body_exited.connect(_on_chase_range_body_exited)

	await get_tree().process_frame
	var enemies = Game.get_singleton().get_data_in_room("Enemies")
	if enemies:
		var enemy = enemies.get(name)
		if enemy:
			load_data(enemy)
func _process(delta: float) -> void:
	if debug: Debugger.printui("facing: "+str(facing))
	if debug: Debugger.printui("target_in_sight: "+str(target_in_sight))
func _physics_process(delta: float) -> void:
	if chase_target:
		var pos := chase_target.hurtbox.global_position
		pos.y -= 10
		line_of_sight.target_position = line_of_sight.to_local(pos)
		var collider = line_of_sight.get_collider()
		if collider && collider is CollisionObject2D:
			var owner_id = collider.get_shape_owners()[0]
			if collider.is_shape_owner_one_way_collision_enabled(owner_id):
				line_of_sight.add_exception(collider)
		target_in_sight = !line_of_sight.is_colliding()
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
	if debug:
		Debugger.printui("force_x: "+str(force_x))
	if debug: Debugger.printui("move_speed: "+str(move_speed))
	if !next_step_free(facing):
		stop_force_x()
	velocity.x = (move_speed + force_x) * delta * 60
	move_speed = 0.0; # Reset move speed since, this needs setting each frame
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
	if is_on_floor():
		if last_ground_y == 0: last_ground_y = position.y # Means this is the first physics frame
		var fall_damage := 0.0
		var fall_distance := position.y - last_ground_y
		if fall_distance > 32:
			print("fall_distance: "+str(fall_distance))
			fall_damage = round(fall_distance/8)
			print("fall_damage: "+str(fall_damage))
			take_damage(fall_damage)

		last_ground_y = position.y
	#endregion
	#region Finalize
	floor_max_angle = 1
	move_and_slide()
	if cp.pushback_vector.x != 0:
			set_facing(-sign(cp.pushback_vector.x))
	#else:
	#	if(!facing_locked && velocity.x != 0):
	#		set_facing(sign(velocity.x))

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
func _on_chase_detector_body_entered(body:Player) -> void:
	if debug: print("Player body entered chase detector")
	assign_chase_target(body)
func _on_chase_range_body_exited(body:Player) -> void:
	if debug: print("Player body exited chase range")
	drop_chase()
func _on_crush_check_body_entered(body:Node2D) -> void:
	if body is Movable && body.velocity.y > 0:
		call_deferred("set_collision_mask_value", 1, false)
		state_node.state.finished.emit("death")
func _on_awareness_timer_timeout() -> void:
	if debug: print("Lost awareness")
	aware = false
func _on_threat_collider_body_entered(body:Node2D) -> void:
	enviroment_kill("death")
func _on_spike_ground_collider_body_entered(body: Node2D) -> void:
	enviroment_kill("death_spike_ground")
func _on_spike_wall_check_body_entered(body: Node2D) -> void:
	print("Spike wall")
	global_position.x += sign(combat_properties.pushback_vector.x) * 16
	enviroment_kill("death_spike_wall")
func _on_player_proximity_body_entered(body:Player) -> void:
	if !body.hiding:
		if debug: print("Start chase by proximity trigger")
		assign_chase_target(body)
		aware = true
func _on_enter_shadow() -> void:
	in_shadow = true
	var c = Color(0.1, 0.1, 0.1, 0.5)
	create_tween().bind_node(self).tween_property(sprite.material, "shader_parameter/tint_color", c, 0.2)
func _on_leave_shadow() -> void:
	in_shadow = false
	var c = Color(0.0, 0.0, 0.0, 0.0)
	create_tween().bind_node(self).tween_property(sprite.material, "shader_parameter/tint_color", c, 0.2)
#endregion
