extends PlayerState

@onready var recovery_timer : Timer = $RecoveryTimer
@onready var sex_timer : Timer = $SexTimer
@onready var participant_collider : Area2D = $SexParticipantCollider

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.velocity.x = 0

	for buff in player.buff_container.get_children():
		if buff.effect == "death's door":
			player.dead = true
			player.unconscious = false
			buff.queue_free()
			break

	if !player.dead:
		player.unconscious = true
		recovery_timer.start()
		sex_timer.start()

	print("recovery_timer.time_left: "+str(recovery_timer.time_left));

	# Decide what to do if dead

func exit() -> void:
	recovery_timer.stop()
	sex_timer.stop()

func update(delta: float) -> void:
	if player.unconscious:
		if recovery_timer.is_stopped():
			finished.emit("recover")

		if sex_timer.is_stopped():
			player.can_have_sex = true
			if participant_collider.has_overlapping_bodies():
				for body in participant_collider.get_overlapping_bodies():
					#We can handle more characters later
					player.sex_begin([body], "sex_goblin1")
					break
