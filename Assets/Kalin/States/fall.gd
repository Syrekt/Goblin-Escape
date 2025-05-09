extends PlayerState

@onready var land_animation_timer = $LandAnimationTimer
@onready var fall_damage_timer = $FallDamageTimer

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	land_animation_timer.start(0.3)
	fall_damage_timer.start(0.6)

func physics_update(delta: float) -> void:
	if player.is_on_floor():
		if fall_damage_timer.is_stopped():
			finished.emit("land_hurt")
		elif land_animation_timer.is_stopped():
			finished.emit("land")
		else:
			finished.emit("idle")

	if player.can_grab_corner() && player.ray_corner_grab_check.is_colliding():
		var collider = player.ray_corner_grab_check.get_collider()
		if !collider.is_in_group("OneWayColliders"):
			if player.col_auto_climb_bottom.has_overlapping_bodies():
				player.snap_to_corner(player.ray_corner_grab_check.get_collision_point())
				player.quick_climb()
			else:
				finished.emit("corner_grab")
