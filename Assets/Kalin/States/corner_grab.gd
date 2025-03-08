extends PlayerState

var just_entered := false
@export var snap_offset := Vector2(-5, -13)

func enter(previous_path_string: String, data := {}) -> void:
	var ledge_position = player.ray_corner_check.get_collision_point();
	player.global_position = ledge_position + Vector2(snap_offset.x * player.facing, snap_offset.y)
	player.call_deferred("update_animation", "corner_grab")

	just_entered = true

func physics_update(delta: float) -> void:
	pass
	#if just_entered:
	#	while !player.is_on_wall():
	#		print("player.x += player.facing")
	#		player.position.x += player.facing
	#		player.velocity.y = 0;
	#		player.move_and_slide()
	#	while player.is_on_wall():
	#		print("player.x -= player.facing")
	#		player.position.x -= player.facing
	#		player.velocity.y = 0;
	#		player.move_and_slide()
	#	collider.disabled = true
	#	#player.position.x -= 4*player.facing
	#just_entered = false


func update(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		finished.emit("corner_climb")
	if Input.is_action_just_pressed("down"):
		player.ignore_corners = true;
		finished.emit("fall")
