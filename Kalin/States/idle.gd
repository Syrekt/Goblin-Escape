extends PlayerState

var just_climbed := false

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	player.call_deferred("update_animation", name)
	lock_stance_button = true;
	just_climbed = data.get("just_climbed", false)

func update(_delta: float) -> void:
	player.check_movable();
	if lock_stance_button:
		if not player.pressed("stance"): lock_stance_button = false

	if just_climbed:
		await get_tree().physics_frame
		just_climbed = false
	elif !player.is_on_floor():
		finished.emit("fall")
	elif player.pressed("down"):
		finished.emit("crouch")
	elif player.just_pressed("jump"):
		finished.emit("rise")
	elif player.has_sword && !lock_stance_button && (player.just_pressed("stance") || player.just_pressed("attack")):
		finished.emit("stance_light")
	elif player.velocity.x != 0:
		if player.pressed("run") && player.stamina.has_enough(1.0):
			finished.emit("run")
		else:
			finished.emit("walk")
	elif player.ladder:
		if Input.is_action_pressed("up"):
			finished.emit("ladder_climb")
