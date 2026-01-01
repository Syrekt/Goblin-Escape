@icon("res://UI/Map Markers/map_marker_kalin.png")
class_name Player extends CharacterBody2D

#region Movement
@export var run_speed			:= 100.0 * 60.0
@export var walk_speed			:= 50.0 * 60.0
@export var sprint_speed		:= 150.0 * 60.0
@export var stance_walk_speed	:= 30.0 * 60.0
@export var crouch_speed		:= 45.0 * 60.0
@export var push_pull_speed 	:= 25.0 * 60.0
@export var sprint_slide_speed  := 7.0 * 60.0
@export var slide_speed			:= 5.0 * 60.0
@export var slide_dec			:= 7.0
@export var gravity				:= 500.0
@export var jump_impulse		:= 200.0
@export var def_acc				:= 10.0
@export var run_stop_dec		:= 3.0
@export var bash_stop_dec		:= 4.0
@export var jump_move_speed		:= 700.0

@export var snap_offset			:= Vector2(-5, -13)
@export var facing_locked		:= false
@export var direction_locked	:= false

var move_speed := 0.0
var facing := 1
var ignore_corners := false
var controls_disabled := false # Disables movement and UI input for player
var movement_disabled := false # Only disables movement input
var sprinting := false

var last_ground_position : Vector2

var is_on_one_way_collider := false

var remote_control_input : Array[String]

var climb_start_position : Vector2 ## When Kalin takes damage, she is moved to this position

var was_on_floor := false
var coyote := false
#endregion
#region Stats & EXP
const HEALTH_PER_VIT	:= 10
const STAMINA_PER_VIT	:= 2
const LEVEL_UP_BASE_EXP_REQUIREMENT	:= 100
const LEVEL_UP_MOD			:= 10.0
const LEVEL_UP_GROWTH		:= 3.0

@export var vitality := 1
@export var strength := 1
@export var endurance := 1
@export var level := 1
@export var experience_point := 0
var experience_required := 100
#endregion
#region Node pointers
@onready var state_node := $StateMachine
@onready var ui : CanvasLayer = $UI
@onready var ui_modulate : CanvasModulate = $UI/UITint
@onready var hud : Control = find_child("HUD")
@onready var health		: TextureProgressBar = find_child("Health") #$CanvasLayer/HUD/HBoxContainer/Health
@onready var stamina	: TextureProgressBar = find_child("Stamina") #$CanvasLayer/HUD/HBoxContainer/Stamina
@onready var experience : Label = find_child("Experience")
@onready var fatigue	: TextureProgressBar = find_child("Fatigue")
@onready var smell		: TextureProgressBar = find_child("Smell")
@onready var arousal	: TextureProgressBar = find_child("Arousal")
@onready var smell_particles : GPUParticles2D = $SmellParticles
@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var combat_properties = $CombatProperties
@onready var ray_movable : RayCast2D = $MovableCheck
@onready var ray_corner_grab_check : RayCast2D = $CornerGrabCheck
@onready var ray_auto_climb : RayCast2D = $CornerAutoClimb
@onready var ray_stairs_path : RayCast2D = $RayStairsPath
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
@onready var status_effect_container : StatusEffectContainer = find_child("StatusEffectContainer")
@onready var map_scene : PackedScene = preload("res://UI/map.tscn")
@onready var hurtbox : CollisionShape2D = $ColliderStanding
@onready var screen_fade : CanvasLayer = get_tree().current_scene.find_child("ScreenFade")

#endregion
#region Audio
@onready var hurt_sfx 	: FmodEventEmitter2D = $Audio/HurtSFX
@onready var block_sfx 	: FmodEventEmitter2D = $Audio/BlockSFX
@onready var experience_drop_sfx : FmodEventEmitter2D = $Audio/ExperienceGain
@onready var pickup_sfx : FmodEventEmitter2D = $Audio/PickupSFX
@onready var drink_sfx	: FmodEventEmitter2D = $Audio/DrinkSFX
@onready var eat_sfx	: FmodEventEmitter2D = $Audio/EatSFX
@onready var tutorial_sfx	: FmodEventEmitter2D = $Audio/TutorialSFX
@onready var slide_sfx	: FmodEventEmitter2D = $Audio/SlideSFX
@onready var land_sfx	: FmodEventEmitter2D = $Audio/LandSFX
#endregion
#region Combat
const SLASH_DAMAGE	:= 15
const STAB_DAMAGE	:= 10
const BASH_DAMAGE 	:= 10
const SLASH_DAMAGE_PER_STRENGTH	:= 2
const STAB_DAMAGE_PER_STRENGTH	:= 1
const BASH_DAMAGE_PER_STRENGTH 	:= 1
# Stamina costs
const SLASH_STAMINA_COST	:= 2
const STAB_STAMINA_COST		:= 1
const BASH_STAMINA_COST 	:= 2
const SLASH_COST_PER_STRENGTH	:= 0.2
const STAB_COST_PER_STRENGTH	:= 0.15
const BASH_COST_PER_STRENGTH	:= 0.15
const SLASH_COST_PER_ENDURANCE	:= 0.1
const STAB_COST_PER_ENDURANCE	:= 0.08
const BASH_COST_PER_ENDURANCE	:= 0.08
const SLASH_SWEAT	:= 0.2
const STAB_SWEAT	:= 0.1
const BASH_SWEAT	:= 0.1
const MAX_SLASH_FATIGUE	:= 2.0
const MAX_STAB_FATIGUE	:= 1.5
const MAX_BASH_FATIGUE	:= 2.0
const SLASH_FATIGUE_STRENGTH_MOD	:= 0.5
const SLASH_FATIGUE_ENDURANCE_MOD	:= 0.8
const STAB_FATIGUE_STRENGTH_MOD		:= 0.4
const STAB_FATIGUE_ENDURANCE_MOD	:= 0.7
const BASH_FATIGUE_STRENGTH_MOD		:= 0.5
const BASH_FATIGUE_ENDURANCE_MOD	:= 0.8
const SLASH_SWEAT_PER_STRENGTH	:= 0.06
const STAB_SWEAT_PER_STRENGTH	:= 0.02
const BASH_SWEAT_PER_STRENGTH	:= 0.06

var had_sword := false ## Variable to track if player got a sword at any point
@export var has_sword := false: ## False for release
	set(value):
		if !has_sword && value && Ge.show_tutorials:
			var tutorial = load("res://Tutorial/combat_tutorial.tscn").instantiate()
			#get_tree().current_scene.add_child.call_deferred("tutorial")
		has_sword = value
		if has_sword: had_sword = true
	get:
		return has_sword
	
var in_combat_state := false
var combat_target	: CharacterBody2D = null
var buffered_state  : String
var parried			:= false
@export var power_crush	:= false
var absorbed_damage := false
var enemies_on_chase: Array[Enemy]
var can_be_grabbed := false
var grabbed_by : Enemy
@export var has_heavy_stance		:= false
@export var has_defensive_stance	:= false
var slash_cost	: float
var stab_cost	: float
var bash_cost 	: float
#endregion
#region Camera
@onready var pcam_noise_emitter : PhantomCameraNoiseEmitter2D = find_child("PhantomCameraNoiseEmitter2D")
@onready var noise_emitter_light_shake : PhantomCameraNoise2D = preload("res://Kalin/PCamNoiseEmitters/light_shake.tres")
@onready var noise_emitter_heavy_shake : PhantomCameraNoise2D = preload("res://Kalin/PCamNoiseEmitters/heavy_shake.tres")
#endregion
#region Others
@export var debug				:= false
@export var dead				:= false ## Health == 0
@export var unconscious			:= false ## Post sex situations where health isn't 0
var can_have_sex := false ## When enemies can move in for sex
var states_locked := false
@export var save_list : Array[String]
@onready var pcam : PhantomCamera2D = $PhantomCamera2D
var movable : Node2D = null
var noise = preload("res://Objects/noise.tscn")
var hiding_spot : Interaction
var hiding := false ## Hiding in a spot
var invisible := false ## Can't be seen in dark
var current_tint : Color = Color(0.0, 0.0, 0.0, 1.0)
var ladder : Area2D
const ingame_menu = preload("res://UI/ingame_menu.tscn")
var corner_quick_climb := false
var sex_participants : Array
var light_source : Area2D
var ray_light : RayCast2D
var wait_for_camera := false
var map_icon := "player"
var draw_on_map := true
var potential_movable : Movable
var disable_camera_damping_on_spawn := true
var hud_tween : Tween
#endregion
#region Signals
signal enter_shadow
signal leave_shadow
signal enter_abyss
signal grabbed
signal fullscreen_panel_opened
signal fullscreen_panel_closed
#endregion
#region Save List
#endregion
#region Methods
func set_facing(dir: int):
	if dir == 0: return
	facing = sign(dir)
	var local_nodes = find_children("*", "Node", true).filter(func(n): return n.is_in_group("Flip"))
	for node in local_nodes:
		if node == ray_corner_grab_check:
			node.position.x = 8 * facing
		elif node is Sprite2D:
			node.flip_h = facing == -1
		else:
			node.scale.x = facing
func get_movement_dir() -> float:
	if movement_disabled:
		return int(remote_control_input.has("right")) - int(remote_control_input.has("left"))
	else:
		return sign(Input.get_axis("left", "right"))
func fall(delta):
	velocity.y += gravity * delta
	move_and_slide()
func take_damage(_damage: int, _source: Node2D = null, play_hurt_animation := true, attack := {}):
	var noise_type = noise_emitter_light_shake

	var state_name = state_node.state.name
	if !can_be_attacked():
		return
	# This breaks the shadow tint when Kalin takes damage in shadows
	#%Sprite2D.material.set_shader_parameter("tint_color", Color(0, 0, 0, 0))

	combat_properties.stunned = false
	var defending : bool = state_node.state.name == "stance_defensive"
	var defended := false

#region Damage has a source
	#Parry
	if _source:
		var incoming_attack = _source.state_node.state.name

		match incoming_attack:
			"slash", "bash":
				noise_type = noise_emitter_heavy_shake


		var parry_active := false
		var perfect_parry := false
		var perfect_parry_window : float = parry_timer.wait_time / 5 * 4
		if !_source.counter_attack && incoming_attack == "stab":
			parry_active = !parry_timer.is_stopped()
			perfect_parry = parry_timer.time_left >= perfect_parry_window

		if incoming_attack != "slash" && defending:
			if !perfect_parry:
				if !stamina.spend(1, 1.0):
					block_sfx.set_parameter("Block", "Fail")
					block_sfx.play()
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
					block_sfx.set_parameter("Block", "Success")
					if parry_active:
						parried = true
						smell.get_dirty(2.0)
						if perfect_parry:
							Ge.slow_mo(0.25, 0.50)
							block_sfx.set_parameter("Block", "PerfectParry")
						else:
							Ge.slow_mo(0.25, 0.25)
							block_sfx.set_parameter("Block", "Parry")
						_source.combat_properties.stun(2.0)
				"slash":
					combat_properties.stun(2.0)
					play_hurt_animation = false
					defended = false
					block_sfx.set_parameter("Block", "Fail")
			block_sfx.play()
#endregion
	#Take damage (abort if dead)
	if !defended:
		smell.get_dirty(6.0)
		if power_crush:# && stamina.spend(_damage, 1.0):
			play_hurt_animation = false
			absorbed_damage = true
			hurt_sfx.set_parameter("DamageType", "EnemyAttack")
			Ge.slow_mo(0, 0.2)
			var tween_tint = create_tween().bind_node(self)
			var tween_outline = create_tween().bind_node(self)
			tween_tint.tween_property(sprite.material, "shader_parameter/tint_color", Color.WHITE, 0)
			#tween_outline.tween_property(sprite.material, "shader_parameter/outline_color", Color(0.7, 0.24, 1.0, 1), 0)
			tween_outline.tween_property(sprite.material, "shader_parameter/outline_color", Color.WHITE, 0)
			tween_tint.tween_property(sprite.material, "shader_parameter/tint_color", current_tint, 0.5)
			tween_outline.tween_property(sprite.material, "shader_parameter/outline_color", Color(0, 0, 0, 0), 0.5)
		else:
			Ge.slow_mo(0, 0.1)
		health.value -= _damage
		health._on_update_health_timer_timeout()
		if Options.screenshake_enabled:
			pcam_noise_emitter.set_noise(noise_type)
			pcam_noise_emitter.emit()
		if health.value <= 0.1:
			print("Health depleted")
			if _source:
				_source.dealth_finishing_blow = true
			hurt_sfx.play()
			state_node.state.finished.emit("death", {"source" = _source})
			return
	#Play animation
	if play_hurt_animation:
		if state_name == "corner_climb":
			global_position = climb_start_position

		if has_sword:
			state_node.state.finished.emit("hurt")
		else:
			state_node.state.finished.emit("hurt_no_sword")
		hurt_sfx.play()
func heal(amount: int) -> void:
	health.value += amount
func check_movable():
	if ray_movable.is_colliding(): 
		potential_movable = ray_movable.get_collider();
		potential_movable.interaction_prompt._show("grab", "Push")
	elif potential_movable:
		potential_movable.interaction_prompt._hide()
		potential_movable = null


	if just_pressed("grab") && potential_movable != null && !potential_movable.falling:
		movable = potential_movable
		state_node.state.finished.emit("push_idle")

func check_interactable() -> void:
	if !in_combat_state:
		var interactions = col_interaction.get_overlapping_areas()
		if interactions.size() == 0:
			interaction_prompt._hide()
		for interaction : Interaction in interactions:
			if interaction.interactable:
				interaction.update(self)
			if !interaction.auto && interaction.interactable:
				interaction_prompt._show("interact", interaction.title)
				break
func can_grab_corner(rising := false) -> bool:
	var grab_prevent = col_corner_grab_prevent.has_overlapping_bodies()

	if grab_prevent: return false
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
	state_node.state.finished.emit("corner_climb")
func sex_begin(participants: Array, _position: String) -> void:
	sex_participants = participants.duplicate()
	print("sex_participants: "+str(sex_participants))
	for participant in sex_participants:
		participant.state_node.state.finished.emit("sex")
	state_node.state.finished.emit("sex")
	call_deferred("update_animation", _position)
func emit_noise(offset:Vector2, amount := 0.0) -> void:
	var feather_step = status_effect_container.has_status_effect("Feather Step")
	# Muffle
	var noise_muffle := 0.0

	# Noise
	if amount == 0.0:
		match state_node.state.name:
			"run":
				amount = 50.0 if sprinting else 30.0
				if feather_step: amount = 0.0
			"walk":
				amount = 0.0
			"stab":
				amount = 10.0
			"slash":
				amount = 20.0
			"block":
				amount = 30.0
			"bash", "bash_running", "bash_no_sword":
				amount = 20.0
				if feather_step: amount = 0.0
			"land_hurt":
				amount = 20.0
				if feather_step: amount = 0.0
			"land_short":
				amount = 5.0
				if feather_step: amount = 0.0
			"land":
				amount = 10.0
				if feather_step: amount = 0.0

	#Finalize
	if(amount - noise_muffle > 0.0):
		var _noise = noise.instantiate()
		_noise.amount_max = max(amount - noise_muffle, 0)
		_noise.global_position = global_position + offset
		_noise.source = self

		add_sibling(_noise)
func toggle_inventory():
	if controls_disabled: return
	inventory_panel.toggle()
func toggle_character_panel():
	if controls_disabled: return
	if !character_panel.visible:
		character_panel.open()
	else:
		character_panel.close()
func toggle_map():
	if controls_disabled: return
	var map : Map = get_tree().current_scene.get_node_or_null("Map")
	if !map:
		map = map_scene.instantiate()
		get_tree().current_scene.add_child(map)
	else:
		map.queue_free()
func check_controls_disabled() -> bool:
	var ui_nodes = get_tree().get_nodes_in_group("FullscreenPanel")
	var node_found := false
	for node in ui_nodes:
		if node.visible:
			interaction_prompt.supress = true
			#Debugger.printui("Controls disabled, FullscreenPanel detected: %s" % node.name)
			node_found = true
			break
	if node_found:
		if !controls_disabled:
			fullscreen_panel_opened.emit();
	elif controls_disabled:
		fullscreen_panel_closed.emit()
	return node_found
func check_movement_disabled() -> bool:
	if controls_disabled: return true
	var ui_nodes = get_tree().get_nodes_in_group("UIPanel")
	for node in ui_nodes:
		if node.visible:
			interaction_prompt.supress = true
			#Debugger.printui("Movement disabled, UI panel detected: %s" % node.name)
			#Debugger.printui("node: "+str(node))
			return true
	return false
func pressed(input : String) -> bool:
	if movement_disabled: return false
	return Input.is_action_pressed(input)
func just_pressed(input : String) -> bool:
	if movement_disabled: return false
	return Input.is_action_just_pressed(input)
func just_released(input : String) -> bool:
	if movement_disabled: return false
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
	pass
	#if !in_combat_state:
	#	think("I should be careful")
func save(save_manager: RefCounted) -> void:
	var save_data = {
		"pos_x"		: position.x,
		"pos_y"		: position.y,
		"health"	: health.value,
		"stamina"	: stamina.value,
		"arousal"	: arousal.value,
		"smell"		: smell.value,
		"fatigue"	: fatigue.value,
		"experience": experience.amount,
	}

	for i in save_list:
		var value = get(i)
		print(i + ": "+str(value))
		if i in self:
			save_data[i] = get(i)
		else:
			print("Unkown value, can't save " + i)
	#Ge.save_node(self, save_data)
	inventory_panel.save(save_data)
	status_effect_container.save(save_data)
	save_manager.set_value("kalin", save_data)
func load(data: Dictionary) -> void:
	print("Loaded player data: "+str(data))
	health.value	= data.health
	stamina.value	= data.stamina
	arousal.value	= data.arousal
	smell.value		= data.smell
	fatigue.value	= data.fatigue
	experience.amount = data.experience

	data.erase("health")
	data.erase("stamina")
	data.erase("arousal")
	data.erase("smell")
	data.erase("fatigue")

	for key in data.keys():
		set(key, data[key])
	disable_camera_damping_on_spawn = true
	global_position = Vector2(data.pos_x, data.pos_y)
	inventory_panel.load(data)
	status_effect_container.load(data.get("Status Effects"))
func check_buffered_state() -> bool:
	var state_to_switch : String
	if buffered_state:
		match buffered_state:
			"slash":
				if has_heavy_stance && stamina.spend(slash_cost, get_slash_sweat_cost()):
					state_to_switch = "slash"
			"stab":
				if stamina.spend(stab_cost, get_stab_sweat_cost()):
					state_to_switch = "stab"
			"bash":
				if has_defensive_stance && stamina.spend(bash_cost, get_bash_sweat_cost()):
					state_to_switch = "bash"
	buffered_state = ""
	if state_to_switch:
		state_node.state.finished.emit(state_to_switch)
		return true
	return false
func get_grabbed(enemy: Enemy, state: String) -> void:
	state_node.state.finished.emit(state)
	grabbed_by = enemy
func break_grab() -> void:
	state_node.state.finished.emit("break_free")
	grabbed_by = null # Enemy will change it's state to 'shoved'
func level_up() -> void:
	experience_point -= experience_required
	experience.lose(experience_required)
	level += 1
	experience_required = get_exp_required_for_level(level + 1)
	print("Experience required for the next level: "+str(experience_required))
func get_exp_required_for_level(_level:int) -> int:
	print("Get level requiredment for %d" %_level)
	var base_requirement := 100
	var mod		:= 10.0
	var growth	:= 3.0
	return ceil(LEVEL_UP_BASE_EXP_REQUIREMENT * _level + LEVEL_UP_MOD * pow(_level, LEVEL_UP_GROWTH))
func calculate_stats() -> void:
	health.value_max = 100 + HEALTH_PER_VIT * vitality
	stamina.value_max = 5 + STAMINA_PER_VIT * vitality
func get_slash_sweat_cost() -> float:
	return SLASH_SWEAT + log((SLASH_SWEAT_PER_STRENGTH * strength) + 1)
func get_stab_sweat_cost() -> float:
	return STAB_SWEAT + log((STAB_SWEAT_PER_STRENGTH * strength) + 1)
func get_bash_sweat_cost() -> float:
	return BASH_SWEAT + log((BASH_SWEAT_PER_STRENGTH * strength) + 1)
func can_be_attacked() -> bool: ## Returns false when player is in 'sex_state' or 'strugle_state'
	var groups = state_node.state.get_groups()
	for group in groups:
		if group == "sex_state" || group == "struggle_state" || state_node.state.name == "death":
			return false

	return true
func is_in_state_group(group_name:String) -> bool:
	var groups = state_node.state.get_groups()
	for group in groups:
		if group == group_name:
			return true

	return false
func corner_climb_check_headbump() -> void:
	if col_stand_check.has_overlapping_bodies():
		state_node.state.finished.emit("crouch")
func prevent_corner_grab() -> void:
	ignore_corners = true
	await get_tree().create_timer(0.6).timeout
	ignore_corners = false
func ignore_platforms() -> void:
	set_collision_mask_value(17, false)
	set_collision_mask_value(14, false)
	await get_tree().create_timer(0.5).timeout
	set_collision_mask_value(17, true)
	set_collision_mask_value(14, true)
func unlock_skill(_name: String) -> void:
	print("Unlocked skill: %s" % _name)
	set(_name, true)
	match _name:
		"has_heavy_stance":
			if Ge.show_tutorials:
				var tutorial = load("res://Tutorial/heavy_stance_tutorial.tscn").instantiate()
				get_tree().current_scene.add_child(tutorial)
				await tutorial.tree_exited
				think("I can break the barricades now.")
		"has_defensive_stance":
			if Ge.show_tutorials:
				var tutorial = load("res://Tutorial/defensive_stance_tutorial.tscn").instantiate()
				get_tree().current_scene.add_child(tutorial)
func on_enter() -> void:
	var state = state_node.state.name
	match state:
		"rise":
			velocity.y = -jump_impulse
		# Disabled since fall damage on room change might work
		#"fall":
		#	state_node.state.fall_start_y = global_position.y
	pcam.follow_damping = false
	await get_tree().create_timer(0.5).timeout
	pcam.follow_damping = true
func toggle_pause_menu() -> void:
		var ui_nodes = get_tree().get_nodes_in_group("FullscreenPanel")
		var node_found := false
		for node in ui_nodes: if node.visible: return
		ui_nodes = get_tree().get_nodes_in_group("UIPanel")
		for node in ui_nodes: if node.visible: return

		var open_menu : MainMenu = get_tree().current_scene.get_node_or_null("IngameMenu")
		if !open_menu:
			open_menu = ingame_menu.instantiate()
			get_tree().current_scene.add_child(open_menu)
func get_slash_damage(_str:=strength) -> float:
	return SLASH_DAMAGE + _str * SLASH_DAMAGE_PER_STRENGTH
func get_stab_damage(_str:=strength) -> float:
	return STAB_DAMAGE + _str * STAB_DAMAGE_PER_STRENGTH
func get_bash_damage(_str:=strength) -> float:
	return BASH_DAMAGE + _str * BASH_DAMAGE_PER_STRENGTH
func get_slash_stamina_cost(_str:=strength,end:=endurance) -> float:
	return SLASH_STAMINA_COST + _str * SLASH_COST_PER_STRENGTH - end * SLASH_COST_PER_ENDURANCE
func get_stab_stamina_cost(_str:=strength,end:=endurance) -> float:
	return STAB_STAMINA_COST + _str * STAB_COST_PER_STRENGTH - end * STAB_COST_PER_ENDURANCE
func get_bash_stamina_cost(_str:=strength,end:=endurance) -> float:
	return BASH_STAMINA_COST + _str * BASH_COST_PER_STRENGTH - end * BASH_COST_PER_ENDURANCE
func get_slash_sweat_buildup(_str:=strength) -> float:
	return SLASH_SWEAT + log(_str * SLASH_SWEAT_PER_STRENGTH + 1)
func get_stab_sweat_buildup(_str:=strength) -> float:
	return STAB_SWEAT + log(_str * STAB_SWEAT_PER_STRENGTH + 1)
func get_bash_sweat_buildup(_str:=strength) -> float:
	return BASH_SWEAT + log(_str * BASH_SWEAT_PER_STRENGTH + 1)
func get_slash_fatigue(_str:=strength,end:=endurance) -> float:
	return (float(_str) / float(_str + end)) * MAX_SLASH_FATIGUE
func get_stab_fatigue(_str:=strength,end:=endurance) -> float:
	return (float(_str) / float(_str + end)) * MAX_STAB_FATIGUE
func get_bash_fatigue(_str:=strength,end:=endurance) -> float:
	return (float(_str) / float(_str + end)) * MAX_BASH_FATIGUE
#endregion
#region Animation Ending
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	var state = state_node.state

	match state.name:
		"land", "land_hurt", "run_stop", "land_short":
			state.finished.emit("idle")
		"recover":
			state.finished.emit("idle")
			heal(1)
		"stab", "slash", "bash", "block":
			if !check_buffered_state():
				if pressed("up") && has_heavy_stance:
					state.finished.emit("stance_heavy")
				elif pressed("down") && has_defensive_stance:
					state.finished.emit("stance_defensive")
				else:
					state.finished.emit("stance_light")
		"bash_no_sword":
			if has_sword && combat_target:
				state.finished.emit("stance_light")
			else:
				state.finished.emit("idle")
		"break_free":
			if has_sword:
				state.finished.emit("stance_light")
			else:
				state.finished.emit("idle")
		"hurt", "hurt_no_sword":
			if can_stand_up():
				if combat_target && has_sword:
					state.finished.emit("stance_light")
				else:
					state.finished.emit("idle")
			else:
				state.finished.emit("crouch")
			grabbed_by = null
		"corner_climb", "corner_climb_quick":
			#global_position += Vector2(26*facing, -35)
			#await get_tree().physics_frame
			if can_stand_up():
				state.finished.emit("idle")
			else:
				state.finished.emit("crouch")
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
			state.finished.emit("struggle_goblin")
		"crawl_out":
			state.finished.emit("get_up")
		"get_up":
			state.finished.emit("idle")
		"struggle_transition_goblin":
			sex_begin([grabbed_by], "struggle_sex_goblin1")
#endregion
#region Init
func _ready() -> void:
	#SentrySDK.add_breadcrumb(SentryBreadcrumb.create("Just about to welcome the World."))
	#SentrySDK.capture_message("Hello, World!")

	$Overlays.show()
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
	fullscreen_panel_opened.connect(_on_fullscreen_panel_opened)
	fullscreen_panel_closed.connect(_on_fullscreen_panel_closed)
	Ge.player = self
	if OS.is_debug_build():
		has_sword = true
		has_heavy_stance = true
		has_defensive_stance = true
	#get_tree().current_scene.emit_signal("player_ready", self) #owner should be root node
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


	if !$RayUpstairsCheck.is_colliding() && $StairCheck.has_overlapping_bodies():
		# If ray isn't colliding with upstairs
		# And StairCheck is colliding with downstairs
		set_collision_mask_value(12, true)
	elif get_floor_angle() == 0.0 && !$RayUpstairsCheck.is_colliding():
		# Disable upstairs collision if Kalin is on flat ground
		set_collision_mask_value(12, false)

	# Player activates upstair collision manually
	if Input.is_action_pressed("up") || velocity.y > 0.0:
		set_collision_mask_value(12, true)


	if Input.is_action_pressed("up") || Input.is_action_pressed("sprint"):
		set_collision_mask_value(14, true)
	elif !ray_stairs_path.is_colliding():
		set_collision_mask_value(14, false)
	if get_floor_angle() != 0.0:
		set_collision_mask_value(14, false)

	match state_name:
		"idle", "crouch":
			move_speed = 0
		"crouch_walk":
			move_speed = crouch_speed * dir_x
		"walk":
			move_speed = walk_speed * dir_x
		"stance_walk":
			move_speed = stance_walk_speed * dir_x
		"run":
			if sprinting:
				move_speed = sprint_speed * dir_x
			else:
				move_speed = run_speed * dir_x
		#"rise", "fall":
		#	move_speed = stance_walk_speed * dir_x
		"push_idle":
			move_speed = 0
		"push", "pull":
			if state_name == "push" && movable.is_on_wall():
				move_speed = 0
			elif pressed("sprint") && stamina.has_enough(0.1):
				stamina.spend(0.02, 0.01)
				move_speed = push_pull_speed * 2 * dir_x
			else:
				move_speed = push_pull_speed * dir_x
		"run_stop":
			#Make sure that player can't start moving again if it's stopped by an obstacle in this state
			move_speed = walk_speed * dir_x if velocity.x == 0.0 else 0.0
			accelaration = run_stop_dec
		"bash", "bash_no_sword":
			move_speed = 0
		"slide", "stun":
			accelaration = slide_dec
		"land", "land_hurt", "land_short":
			move_speed = 0;
			accelaration = slide_dec
		"slash", "stab":
			move_speed = 0;
			accelaration = slide_dec
		"corner_grab", "corner_climb", "corner_hang":
			move_speed = 0
			velocity = Vector2.ZERO
		"hurt", "hurt_no_sword":
			velocity.x = 0
			move_speed = 0
			accelaration = slide_dec
		"death", "sex", "recover", "struggle_goblin", "goblin_grab", "break_free":
			move_speed = 0
			velocity.x = 0
		"hiding", "hidden", "unhide", "crawl_in":
			move_speed = 0
			velocity = Vector2.ZERO
		"stance_light", "stance_heavy", "stance_defensive":
			move_speed = 0
			velocity = Vector2.ZERO
	var being_careful = state_name == "stance_walk" || state_name == "crouch_walk" || state_name == "rise" || state_name == "walk"
	$ThreatCollider.monitoring = (velocity.x != 0 || velocity.y > 0) && !being_careful


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
	set_collision_mask_value(18, !is_on_floor())
	if !is_on_floor():
		match state_name:
			"corner_climb", "corner_grab", "corner_hang":
				velocity.y = 0
			"ladder_climb":
				pass
			_:
				velocity.y += gravity * delta
	else:
		if state_node.state.is_in_group("position_reliable"):
			if get_floor_angle() == 0:
				last_ground_position = Vector2(global_position.x - facing*32, global_position.y)
			else:
				last_ground_position = Vector2(global_position.x, global_position.y)

	#endregion
	#region Finalize movement
	move_and_slide()
	#region Coyote
	if !is_on_floor() && was_on_floor:
		coyote = true
		$CoyoteTimer.start()
	was_on_floor = is_on_floor()
	#endregion
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
				if data:
					is_on_one_way_collider = data.is_collision_polygon_one_way(0, 0)
			elif collider.is_in_group("OneWayColliders"):
				is_on_one_way_collider = true

	can_be_grabbed = is_on_floor() && get_floor_angle() == 0
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
#region Interactions
	check_interactable()
#endregion
#endregion
#region Process
func _process(delta: float) -> void:
	#region Attack costs
	slash_cost	= lerp(1.0, MAX_SLASH_FATIGUE, fatigue.value/100) * pow(strength, SLASH_FATIGUE_STRENGTH_MOD)/pow(endurance, SLASH_FATIGUE_ENDURANCE_MOD)
	stab_cost	= lerp(0.5, MAX_STAB_FATIGUE, fatigue.value/100) * pow(strength, STAB_FATIGUE_STRENGTH_MOD)/pow(endurance, STAB_FATIGUE_ENDURANCE_MOD)
	bash_cost 	= lerp(1.0, MAX_BASH_FATIGUE, fatigue.value/100) * pow(strength, BASH_FATIGUE_STRENGTH_MOD)/pow(endurance, BASH_FATIGUE_ENDURANCE_MOD)
	#endregion
	#region Movement and Interaction prompt
	# Movement and control checks change interaction_prompt.supress value
	var no_interaction = state_node.state.is_in_group("no_interaction")
	interaction_prompt.supress = false
	controls_disabled = check_controls_disabled()
	movement_disabled = check_movement_disabled()
	if no_interaction: interaction_prompt.supress = true
	#endregion
	#region Auto climb
	if ray_auto_climb.is_colliding():
		var collider = ray_auto_climb.get_collider()
	#endregion
	#region Camera combat position
	if combat_target:
		if combat_target.state_node.state.name == "death": combat_target = null
		elif !combat_target.chase_target: combat_target = null
	if !controls_disabled && pcam:
		in_combat_state = state_node.state.is_in_group("combat_state")
		if in_combat_state && combat_target:
			pcam.follow_mode = pcam.FollowMode.GROUP
			pcam.set_follow_targets([self, combat_target] as Array[Node2D])
			#pcam.draw_limits = false
		elif pcam.follow_mode == pcam.FollowMode.GROUP:
			pcam.follow_mode = pcam.FollowMode.GLUED
			pcam.set_follow_target(self)
			#if pcam.limit_target:
			#	pcam.draw_limits = true
	#endregion
	#region Open menu & Inventory
	if !controls_disabled && Input.is_action_just_pressed("ui_cancel"):
		toggle_pause_menu()
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()
	#if Input.is_action_just_pressed("map"):
	#	toggle_map()

	#endregion
	#region Debug
	if OS.is_debug_build():
		if debug: Debugger.printui(str(state_node.state.name))
		if Input.is_action_pressed("sprint") && Input.is_action_just_pressed("left_mouse_button"):
			global_position = get_global_mouse_position()
		if just_pressed("quick save"):
			Game.get_singleton().save_game()
		if just_pressed("quick load"):
			Game.get_singleton().load_game()
	if OS.is_debug_build() && Input.is_action_just_pressed("debug1"):
		print("debug1")
		#status_effect_container.add_status_effect("Death's Door")
		#status_effect_container.add_status_effect("Bleed", 5.0, 0.1)
		take_damage(90)
		#experience.add(99999)
		#toggle_character_panel()
		#pcam_noise_emitter.emit()
	#endregion
#endregion
#region Listeners
func _on_hurtbox_area_entered(area: Area2D) -> void:
	print(area)
func _on_enter_shadow() -> void:
	print("enter shadow")
	if hud_tween: hud_tween.kill()
	hud_tween = create_tween().bind_node(self)
	hud_tween.tween_property(hud, "modulate", Color(0.5, 0.5, 0.5, 1.0), 1.0)
	health.fade_out()
	stamina.fade_out()

	invisible = true
	current_tint = Color(0.1, 0.1, 0.1, 0.5)
	create_tween().bind_node(self).tween_property(%Sprite2D.material, "shader_parameter/tint_color", current_tint, 0.2)
	create_tween().bind_node(self).tween_property(vignette.material, "shader_parameter/color", Color(0, 0, 0, 0.3), 0.2)
func _on_leave_shadow() -> void:
	print("leave shadow")
	if hud_tween: hud_tween.kill()
	hud_tween = create_tween().bind_node(self)
	hud_tween.tween_property(hud, "modulate", Color.WHITE, 1.0)
	health.fade_in()
	stamina.fade_in()

	invisible = false
	current_tint = Color(0.0, 0.0, 0.0, 0.0)
	create_tween().bind_node(self).tween_property(%Sprite2D.material, "shader_parameter/tint_color", current_tint, 0.2)
	create_tween().bind_node(self).tween_property(vignette.material, "shader_parameter/color", Color(0, 0, 0, 0), 0.2)
func _on_threat_collider_body_entered(body:Node2D) -> void:
	if power_crush:
		power_crush = false
		print("Power crush disabled by threat")
	take_damage(10)
	velocity.x = 0
	move_speed = 0
	think(["I should move carefully.", "I should move slow."].pick_random())
func _on_smell_collider_body_entered(body: Node2D) -> void:
	if !hiding && body is Enemy:
		body.smell(self)
func _on_abyss_entered(abyss: Area2D) -> void:
	global_position = last_ground_position
	velocity.y = 0
	var fall_damage = abyss.damage
	if health.value <= fall_damage:
		take_damage(fall_damage) # To make sure voices don't overlap with fall voice(?)
	else:
		state_node.state.finished.emit("land_hurt", {"fall_damage": fall_damage})
	#pcam.follow_axis_lock = PhantomCamera2D.FollowLockAxis.XY
	#await get_tree().create_timer(1.0).timeout
	#pcam.follow_axis_lock = PhantomCamera2D.FollowLockAxis.NONE
func _on_fullscreen_panel_opened() -> void:
	var huds = get_tree().get_nodes_in_group("HUD")
	print("Hide HUD")
	for panel in huds:
		panel.hide()
func _on_fullscreen_panel_closed() -> void:
	var huds = get_tree().get_nodes_in_group("HUD")
	print("Show HUD")
	for panel in huds:
		panel.show()
func _on_coyote_timer_timeout() -> void:
	coyote = false
	print("Coyote timer timeout")
#endregion
func _unhandled_key_input(event: InputEvent) -> void:
	if OS.is_debug_build() && event.is_pressed():
		match event.keycode:
			KEY_U:
				toggle_character_panel()
			KEY_O:
				experience.add(9999)
			KEY_V:
				var items = inventory_panel.inventory.items
				for item in items:
					print("item.name: "+str(item.name));
