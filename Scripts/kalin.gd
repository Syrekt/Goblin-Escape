class_name Player extends CharacterBody2D

#region Movement
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

var move_speed := 0.0
var facing := 1
var ignore_corners := false
var controls_disabled := false

var noise_muffle := 0.0

var last_ground_position : Vector2

var is_on_one_way_collider := false

var remote_control_input : Array[String]
#endregion
#region Stats & EXP
var level := 0
var available_stat_points := 5
@export var vitality := 0
@export var strength := 0
@export var dexterity := 0
@export var endurance := 0
#endregion
#region Node pointers
@onready var state_node := $StateMachine
@onready var hud : Control = find_child("HUD")
@onready var health		: TextureProgressBar = find_child("Health") #$CanvasLayer/HUD/HBoxContainer/Health
@onready var stamina	: TextureProgressBar = find_child("Stamina") #$CanvasLayer/HUD/HBoxContainer/Stamina
@onready var experience : TextureProgressBar = find_child("Experience")
@onready var smell		: TextureProgressBar = find_child("Smell")
@onready var arousal	: TextureProgressBar = find_child("Arousal")
@onready var smell_particles : GPUParticles2D = $SmellParticles
@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var combat_properties = $CombatProperties
@onready var ray_movable : RayCast2D = $MovableCheck
@onready var ray_corner_grab_check : RayCast2D = $CornerGrabCheck
@onready var ray_auto_climb : RayCast2D = $CornerAutoClimb
@onready var col_behind : Area2D = $ColBehind
@onready var col_corner_grab_prevent : Area2D = $CornerGrabPrevent
@onready var col_quick_climb_prevent : Area2D = $QuickClimbPrevent
@onready var col_stand_check : Area2D = $StandCheck
@onready var col_auto_climb_bottom : Area2D = $BottomAutoClimb
@onready var col_interaction : Area2D = $Interactor
@onready var col_corner_hang : Area2D = $CornerHangCheck
@onready var col_corner_climb_prevent : Area2D = $CornerClimbPrevent
@onready var cp = combat_properties
@onready var camera : Camera2D = $Camera2D
@onready var audio_emitter : AudioStreamPlayer2D = $MainAudioStreamer
@onready var inventory_panel = find_child("InventoryPanel")
@onready var character_panel = find_child("CharacterPanel")
@onready var thought_container = find_child("ThoughtContainer")
@onready var emote = $Emote
@onready var parry_timer = $StateMachine/stance_defensive/ParryTimer
@onready var vignette = find_child("StealthVignette")
@onready var smell_collider : Area2D = $SmellCollider
@onready var cell_check : RayCast2D = $CellCheck
@onready var interaction_prompt : AnimatedSprite2D = $InteractionPrompt
#endregion
#region Combat
@export var has_sword := false #false for release
var in_combat_state := false
const SLASH_COST	:= 2
const STAB_COST		:= 1
const BASH_COST 	:= 2
var slash_damage	:= 2
var stab_damage		:= 1
var bash_damage 	:= 1
var damage			:= 1
var combat_target	: CharacterBody2D = null
var buffered_state  : String
var parried			:= false
@export var power_crush	:= false
var absorbed_damage := false
var enemies_on_chase: Array[Enemy]
var grabbed_by : Enemy
#endregion
#region Others
@export var debug				:= false
@export var dead				:= false # Health == 0
@export var unconscious			:= false # Post sex situations where health isn't 0
var states_locked := false
@export var save_list : Array[NodePath]
@onready var pcam := $PhantomCamera2D
@onready var pcam_host := $Camera2D/PhantomCameraHost
var movable : Node2D = null
var noise = preload("res://Objects/noise.tscn")
var hiding_spot : Interaction
var hiding := false
var invisible := false
var ladder : Area2D
const ingame_menu = preload("res://UI/ingame_menu.tscn")
var open_menu : Node = null
var interaction_target : Area2D = null
var corner_quick_climb := false
var sex_participants : Array
var light_source : Area2D
var ray_light : RayCast2D
var wait_for_camera := false
#endregion
signal enter_shadow
signal leave_shadow
signal enter_abyss
signal grabbed
#region Methods
func set_facing(dir: int):
	if dir == 0: return
	facing = sign(dir)
	var local_nodes = find_children("*", "Node", true).filter(func(n): return n.is_in_group("Flip"))
	for node in local_nodes:
		if node is Sprite2D:
			node.flip_h = facing == -1
		else:
			node.scale.x = facing
func get_movement_dir() -> float:
	if controls_disabled:
		return int(remote_control_input.has("right")) - int(remote_control_input.has("left"))
	else:
		return Input.get_axis("left", "right")
func fall(delta):
	velocity.y += gravity * delta
	move_and_slide()
func take_damage(_damage: int, _source: Node2D = null, play_hurt_animation := true, attack := {}):
	var state_name = state_node.state.name
	if state_name == "death":
		return
	%Sprite2D.material.set_shader_parameter("tint_color", Color(0, 0, 0, 0))

	combat_properties.stunned = false
	var defending : bool = state_node.state.name == "stance_defensive"
	var defended := false

#region Damage has a source
	#Parry
	if _source:
		var incoming_attack = _source.state_node.state.name
		var parry_active := false
		var perfect_parry := false
		var perfect_parry_window : float = parry_timer.wait_time / 5 * 4
		if !_source.counter_attack && incoming_attack == "stab":
			parry_active = !parry_timer.is_stopped()
			perfect_parry = parry_timer.time_left >= perfect_parry_window

		if defending:
			if !parry_active && !perfect_parry && !stamina.spend(_damage, 1.0):
				defending = false

		#See if attack has broken our defense
		defended = defending
		#Bleed if not defending
		if !defending && _source:
			var incoming_dir = sign(_source.global_position.x - global_position.x)
			Ge.bleed_spurt(global_position, -incoming_dir)
		#Defensive reactions
		if defending:
			match incoming_attack:
				"stab":
					play_hurt_animation = false
					state_node.state.finished.emit("block")
					if parry_active:
						parried = true
						smell.get_dirty(2.0)
						if perfect_parry:
							Ge.slow_mo(0.25, 0.50)
							play_sfx(load("res://SFX/parry1.wav"))
						else:
							Ge.slow_mo(0.25, 0.25)
							play_sfx(load("res://SFX/parry2.wav"))
						_source.combat_properties.stun(2.0)
				"slash":
					combat_properties.stun(2.0)
					play_hurt_animation = false
					defended = false
#endregion
	#Take damage
	if !defended:
		smell.get_dirty(6.0)
		if power_crush:# && stamina.spend(_damage, 1.0):
			play_hurt_animation = false
			absorbed_damage = true
			Ge.play_audio_free(-10, "res://SFX/Kalin/Weapon_Hit_Armour_03_With_Echo_Enhancement.wav")
			Ge.slow_mo(0, 0.2)
			var tween_tint = create_tween().bind_node(self)
			var tween_outline = create_tween().bind_node(self)
			tween_tint.tween_property(sprite.material, "shader_parameter/tint_color", Color.WHITE, 0)
			#tween_outline.tween_property(sprite.material, "shader_parameter/outline_color", Color(0.7, 0.24, 1.0, 1), 0)
			tween_outline.tween_property(sprite.material, "shader_parameter/outline_color", Color.WHITE, 0)
			tween_tint.tween_property(sprite.material, "shader_parameter/tint_color", Color(0, 0, 0, 0), 0.5)
			tween_outline.tween_property(sprite.material, "shader_parameter/outline_color", Color(0, 0, 0, 0), 0.5)
		else:
			Ge.slow_mo(0, 0.1)
		health.value -= _damage
		if health.value <= 0.1:
			print("Health depleted")
			if _source:
				_source.dealth_finishing_blow = true
			Ge.play_audio_from_string_array(global_position, -2, "res://SFX/Kalin/Hurt")
			state_node.state.finished.emit("death")
			return
	#Play animation
	if play_hurt_animation:
		if has_sword:
			state_node.state.finished.emit("hurt")
		else:
			state_node.state.finished.emit("hurt_no_sword")
		Ge.play_audio_from_string_array(global_position, -2, "res://SFX/Kalin/Hurt")
func heal(amount: int) -> void:
	health.value += amount
func check_movable():
	var potential_movable = null
	if ray_movable.is_colliding(): 
		potential_movable = ray_movable.get_collider();

	if just_pressed("grab") && potential_movable != null && !potential_movable.falling:
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
func is_collider_one_way(collider: Object) -> bool:
	if collider is TileMapLayer:
		var cell = collider.local_to_map(cell_check.get_collision_point())
		var data = collider.get_cell_tile_data(cell)
		if data:
			return data.is_collision_polygon_one_way(0, 0)
		else:
			return false
	else:
		return collider.is_in_group("OneWayColliders")

func can_quick_climb() -> bool:
	return velocity.y < -50.0 && !col_quick_climb_prevent.has_overlapping_bodies() && !col_corner_climb_prevent.has_overlapping_bodies() && ray_auto_climb.is_colliding()
func can_stand_up() -> bool:
	return !col_stand_check.has_overlapping_bodies()
func update_animation(anim: String, speed := 1.0, from_end := false) -> void:
	if animation_player.current_animation != anim:
		animation_player.play(&"RESET");
		animation_player.advance(0)
		animation_player.play(anim, -1, speed, from_end)
		#animation_player.stop()
		#animation_player.seek(0.0, true)
		#animation_player.play(anim, -1, speed, from_end)
		animation_player.advance(0)
		%Sprite2D.material.set_shader_parameter("number_of_images", Vector2(%Sprite2D.hframes, %Sprite2D.vframes))
func snap_to_corner(ledge_position: Vector2) -> void:
	global_position = ledge_position + Vector2(snap_offset.x * facing, snap_offset.y)
func quick_climb() -> void:
	corner_quick_climb = true
	state_node.state.finished.emit("corner_climb")
func play_sfx(sfx) -> void:
	var emitter : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	emitter.stream = sfx
	emitter.finished.connect(emitter.queue_free)
	add_child(emitter)
	emitter.play()
	#audio_emitter.stream = sfx
	#audio_emitter.play()
func combat_perform_attack(hitbox: Area2D, _damage: int, whiff_sfx: AudioStreamWAV, hit_sfx: AudioStreamWAV, knockback_force: int) -> void:
	if hitbox.has_overlapping_bodies():
		var body = hitbox.get_overlapping_bodies()[0]
		var was_stunned : bool = body.combat_properties.stunned

		var result : int = Combat.deal_damage(self, _damage, body, knockback_force)
		match result:
			Combat.RESULT_STUN:
				Ge.play_audio(audio_emitter, 1, "res://SFX/Kalin/block_break2.wav")
			Combat.RESULT_WHIFF:
				play_sfx(whiff_sfx)
			Combat.RESULT_HIT:
				play_sfx(hit_sfx)
			Combat.RESULT_BLOCK:
				Ge.play_audio_from_string_array(global_position, 0, "res://SFX/Sword hit shield")
			Combat.RESULT_DEAD:
				Ge.play_audio_from_string_array(global_position, 0, "res://SFX/Kalin/Finishers")
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

	_noise.amount_max = amount - noise_muffle
	_noise.global_position = global_position + offset

	add_sibling(_noise)
func toggle_inventory():
	if controls_disabled: return
	inventory_panel.toggle()
func toggle_character_panel():
	if controls_disabled: return
	character_panel.visible = !character_panel.visible
func check_controls_disabled() -> bool:
	var ui_nodes = get_tree().get_nodes_in_group("UIPanel")
	for node in ui_nodes:
		if node.visible:
			interaction_prompt.supress = true
			#Debugger.printui("Movement disabled, UI panel detected")
			#Debugger.printui("node: "+str(node))
			return true
	interaction_prompt.supress = false
	return false
func pressed(input : String) -> bool:
	if controls_disabled: return false
	return Input.is_action_pressed(input)
func just_pressed(input : String) -> bool:
	if controls_disabled: return false
	return Input.is_action_just_pressed(input)
func just_released(input : String) -> bool:
	if controls_disabled: return false
	return Input.is_action_just_released(input)
func hide_out(_hiding_spot : Area2D) -> void:
	if enemies_on_chase.size() > 0:
		if randi() %2:
			think("I'm detected!")
		else:
			think("They are on to me!")
	else:
		set_collision_layer_value(2, false)
		set_collision_mask_value(4, false)
		hiding_spot = _hiding_spot
		state_node.state.finished.emit("hiding")
func force_unhide() -> void:
	set_collision_layer_value(2, true)
	set_collision_mask_value(4, true)
	print("Forced unhide by something")
	hiding = false
func think(text: String) -> void:
	thought_container.push(text)
	emote.play("talking")
func enemy_heard_noise(enemy: Enemy) -> void:
	if !in_combat_state:
		think("I should be careful")
func save() -> Dictionary:
	var save_dict = {
		"pos_x"	: position.x,
		"pos_y"	: position.y,

		"available_stat_points" : available_stat_points,
		"level"		: level,
		"vitality"	: vitality,
		"strength" 	: strength,
		"dexterity"	: dexterity,
		"endurance"	: endurance,

		"has_sword" : has_sword,
	}
	return save_dict
func check_buffered_state() -> bool:
	var state_to_switch : String
	if buffered_state:
		match buffered_state:
			"slash":
				if stamina.spend(SLASH_COST):
					state_to_switch = "slash"
			"stab":
				if stamina.spend(STAB_COST):
					state_to_switch = "stab"
			"bash":
				if stamina.spend(BASH_COST):
					state_to_switch = "bash"
	buffered_state = ""
	if state_to_switch:
		state_node.state.finished.emit(state_to_switch)
		return true
	return false
func get_grabbed(enemy: Enemy, state: String) -> void:
	state_node.state.finished.emit(state)
	grabbed_by = enemy
	set_facing(grabbed_by.global_position.x - global_position.x)
func break_grab() -> void:
	state_node.state.finished.emit("break_free")
	grabbed_by.state_node.state.finished.emit("chase")
	grabbed_by = null
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
			if !check_buffered_state():
				state.finished.emit("stance_light")
		"bash_no_sword":
			state.finished.emit("idle")
		"hurt", "break_free":
			state.finished.emit("stance_light")
		"hurt_no_sword":
			state.finished.emit("idle")
		"corner_climb", "corner_climb_quick":
			global_position += Vector2(26*facing, -35)
			state.finished.emit("idle", {"just_climbed": true})
		"slide":
			state.finished.emit("crouch")
		"orgasm":
			state.finished.emit("post_sex")
			for participant in sex_participants:
				participant.state_node.state.finished.emit("leave_player")
		"post_sex":
			state.finished.emit("recover")
		"corner_hang":
			state.finished.emit("corner_grab")
		"hiding":
			state.finished.emit("hidden")
		"unhide":
			state.finished.emit("idle")
		"grab_goblin":
			state.finished.emit("struggle")
#endregion
#region Init
func _ready() -> void:
	var canvas = find_child("UI")
	canvas.show()
	hud.show()
	$SmellParticles.show()
	ray_light = RayCast2D.new()
	ray_light.collide_with_bodies = true
	add_child(ray_light)
	enter_shadow.connect(_on_enter_shadow)
	leave_shadow.connect(_on_leave_shadow)
	enter_abyss.connect(_on_abyss_entered)
	get_tree().current_scene.emit_signal("player_ready", self) #owner should be root node
#endregion
#region Physics
func _physics_process(delta: float) -> void:
	#region X Movement
	var state_name = state_node.state.name
	#Don't use input direction for facing if direction_locked
	var dir_x = int(get_movement_dir()) if !direction_locked else facing
	var accelaration = def_acc
	#if get_floor_angle() == 0.0:
	#Ignore stairs if we are not on a slope or 'up' key is not pressed
	#This doesn't cause any issues on downstairs probably becase it gets an angle at the end of a platform
	if Input.is_action_pressed("up") || velocity.y > 0.0:
		set_collision_mask_value(12, true)
	else:
		if get_floor_angle() == 0.0:
			set_collision_mask_value(12, false)

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
		"bash", "bash_no_sword":
			move_speed = 0
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
		"death", "sex", "recover", "struggle", "goblin_grab", "break_free":
			move_speed = 0
			velocity.x = 0
		"hiding", "hidden", "unhide":
			move_speed = 0
			velocity = Vector2.ZERO
	$ThreatCollider.monitoring = abs(move_speed) > stance_walk_speed


	if health.value <= 0 || power_crush: cp.pushback_reset()
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
			"ladder_climb":
				pass
			_:
				velocity.y += gravity * delta
	else:
		last_ground_position = Vector2(global_position.x - facing*32, global_position.y)

	#endregion
	#region Finalize movement
	#floor_max_angle = 1
	move_and_slide()
	if cp.pushback_timer > 0:
			set_facing(-sign(cp.pushback_vector.x))
	else:
		if(!facing_locked && velocity.x != 0):
			set_facing(sign(velocity.x))
	
	is_on_one_way_collider = false
	for i in get_slide_collision_count():
		var collider = cell_check.get_collider()
		if collider:
			if collider is TileMapLayer:
				var cell = collider.local_to_map(cell_check.get_collision_point())
				var data = collider.get_cell_tile_data(cell)
				is_on_one_way_collider = data.is_collision_polygon_one_way(0, 0)
			elif collider.is_in_group("OneWayColliders"):
				is_on_one_way_collider = true

	#endregion
	#region Light raycast
	var in_shadow := false
	if !hiding && light_source && light_source.lit:
		ray_light.target_position = ray_light.to_local(light_source.global_position)
		in_shadow = ray_light.is_colliding()
	else:
		in_shadow = true
	if in_shadow != invisible:
		if in_shadow:
			enter_shadow.emit()
		else:
			leave_shadow.emit()
	#endregion
#endregion
#region Process
func _process(delta: float) -> void:
	interaction_prompt.supress = true
	if debug: Debugger.printui("state name: "+str(state_node.state.name));

	if just_pressed("quick save"):
		Ge.save_game("save1")
	if just_pressed("quick load"):
		Ge.load_game("save1")
	var s = %Sprite2D
	%StatPoints.text = "Stat Points: " + str(available_stat_points)
	if debug: Debugger.printui(str(state_node.state.name))
	controls_disabled = check_controls_disabled()
	if ray_auto_climb.is_colliding():
		var collider = ray_auto_climb.get_collider()
	#region Camera combat position
	if !controls_disabled:
		in_combat_state = state_node.state.is_in_group("combat_state")
		if in_combat_state && combat_target:
			pcam.follow_mode = pcam.FollowMode.GROUP
			pcam.set_follow_targets([self, combat_target] as Array[Node2D])
			pcam.draw_limits = false
			if combat_target.state_node.state.name == "death": combat_target = null
			elif !combat_target.chase_target: combat_target = null
		elif pcam.follow_mode == pcam.FollowMode.GROUP:
			pcam.follow_mode = pcam.FollowMode.SIMPLE
			pcam.set_follow_target(self)
			pcam.erase_follow_targets(combat_target)
			if pcam.limit_target:
				pcam.draw_limits = true
	#endregion
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	#region Open menu & Inventory
	if Input.is_action_just_pressed("ui_cancel"):
		if !open_menu:
			open_menu = ingame_menu.instantiate()
			add_child(open_menu)
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()
	if Input.is_action_just_pressed("character"):
		toggle_character_panel()

	#endregion
	if Input.is_action_just_pressed("debug1"):
		print("debug1")
		#think("I smell [color=green]Goblin[/color] [color=red]COCK[/color] UwU")
		take_damage(9)
		#if randi_range(0, 1) == 1:
		#	inventory.pickup_item(load("res://Inventory/water.tres"))
		#else:
		#	inventory.pickup_item(load("res://Inventory/health_potion.tres"))

	check_interactable()
#endregion
#region Signals
func _on_hurtbox_area_entered(area: Area2D) -> void:
	print(area)
func _on_interactor_area_entered(area: Area2D) -> void:
	print("interactor area entered")
	print("area: "+str(area.name))
	interaction_target = area
	if !interaction_target.auto:
		interaction_prompt._show(area.title)
func _on_interactor_area_exited(area: Area2D) -> void:
	if interaction_target == area:
		interaction_target.waiting_player_exit = false
		interaction_target = null
		interaction_prompt._hide()
func _on_enter_shadow() -> void:
	invisible = true
	var c = Color(0.1, 0.1, 0.1, 0.5)
	create_tween().bind_node(self).tween_property(%Sprite2D.material, "shader_parameter/tint_color", c, 0.2)
	create_tween().bind_node(self).tween_property(vignette.material, "shader_parameter/alpha", 0.2, 0.2)
func _on_leave_shadow() -> void:
	invisible = false
	var c = Color(0.0, 0.0, 0.0, 0.0)
	create_tween().bind_node(self).tween_property(%Sprite2D.material, "shader_parameter/tint_color", c, 0.2)
	create_tween().bind_node(self).tween_property(vignette.material, "shader_parameter/alpha", 0.0, 0.2)
func _on_threat_collider_body_entered(body:Node2D) -> void:
	take_damage(1)
	velocity.x = 0
	move_speed = 0
func _on_smell_collider_body_entered(body: Node2D) -> void:
	if !hiding && body is Enemy:
		body.smell(self)
func _on_abyss_entered() -> void:
	global_position = last_ground_position
	var fall_damage = 2
	if health.value <= fall_damage:
		take_damage(2)#To make sure voices don't overlap
	else:
		state_node.state.finished.emit("land_hurt", {"fall_damage": 2})
#endregion
