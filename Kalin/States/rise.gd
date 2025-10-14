extends PlayerState

var jump_boost : float
var cut_ground_contact : bool

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = -player.jump_impulse
	cut_ground_contact = false
	if player.can_grab_corner() && player.ray_auto_climb.is_colliding():
		player.quick_climb()
	else:
		player.call_deferred("update_animation", name)

	jump_boost = 6.0
	var tween = create_tween().bind_node(self)
	tween.tween_property(self, "jump_boost", 0.0, 0.4).set_ease(Tween.EASE_OUT)

func update(delta):
	player.velocity.x += player.facing * jump_boost
	# This allows player to add some speed mid air
	#player.velocity.x += player.get_movement_dir() * player.jump_move_speed * delta
	if !player.is_on_floor():
		cut_ground_contact = true

	if player.can_grab_corner():
		if player.ray_corner_grab_check.is_colliding():
			var collider = player.ray_corner_grab_check.get_collider()
			if !player.is_collider_one_way(collider):
				if player.col_auto_climb_bottom.has_overlapping_bodies():
					player.quick_climb()
				else:
					finished.emit("corner_grab")
		elif player.can_quick_climb():
			var collider = player.ray_auto_climb.get_collider()
			if !player.is_collider_one_way(collider):
				player.quick_climb()

	var on_floor = player.is_on_floor()
	Debugger.printui("on_floor: "+str(on_floor))
	var velocity = player.velocity
	Debugger.printui("velocity: "+str(velocity))
	if cut_ground_contact && player.is_on_floor():
		finished.emit("idle")
	elif player.velocity.y >= 0:
		finished.emit("fall")
