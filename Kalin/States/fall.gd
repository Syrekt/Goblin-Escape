extends PlayerState

@onready var land_animation_timer := $LandAnimationTimer
@onready var grab_timer := $GrabTimer

var fall_start_y : float

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	land_animation_timer.start(0.6)
	grab_timer.start(0.1)
	fall_start_y = player.global_position.y
	player.col_corner_grab_prevent.set_collision_mask_value(17, false)

func exit() -> void:
	player.col_corner_grab_prevent.set_collision_mask_value(17, true)

func physics_update(delta: float) -> void:
	var fall_distance_to_hurt := 128
	var fall_distance_to_stumble := 64

	player.velocity.x += player.get_movement_dir() * player.jump_move_speed * delta

	# Stop ignoring corners
	if player.pressed("up"):
		player.ignore_corners = false

	# Fall Damage
	if player.is_on_floor():
		var fall_damage = 0;
		var fall_distance = player.global_position.y - fall_start_y
		if player.debug: print("fall_distance: "+str(fall_distance))
		if abs(player.global_position.y - fall_start_y) > fall_distance_to_hurt:
			fall_damage = round((player.global_position.y - fall_start_y)/8)
		if player.debug: print("fall_damage: "+str(fall_damage))
		if fall_damage > 0:
			fall_damage = max(fall_damage, 10) # Apply minimum of 10 damage
			finished.emit("land_hurt", {"fall_damage" : fall_damage})
		elif land_animation_timer.is_stopped():
			finished.emit("land")
		elif fall_distance > fall_distance_to_stumble:
			finished.emit("land_short")
		else:
			finished.emit("idle")

	# Corner grab
	if !player.pressed("down") && grab_timer.is_stopped() && player.can_grab_corner() && player.ray_corner_grab_check.is_colliding():
		if player.col_auto_climb_bottom.has_overlapping_bodies():
			player.snap_to_corner(player.ray_corner_grab_check.get_collision_point())
			player.quick_climb()
		else:
			finished.emit("corner_grab")
	
	# Ladder
	if player.ladder:
		if Input.is_action_pressed("up") || Input.is_action_pressed("down"):
			finished.emit("ladder_climb")
