extends PlayerState

@onready var recovery_timer : Timer = $RecoveryTimer
@onready var sex_timer : Timer = $SexTimer
@onready var participant_collider : Area2D = $SexParticipantCollider

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	recovery_timer.start()
	sex_timer.start()
	player.velocity.x = 0

func update(delta: float) -> void:
	if recovery_timer.is_stopped():
		finished.emit("recover")

	if sex_timer.is_stopped():
		if participant_collider.has_overlapping_bodies():
			for body in participant_collider.get_overlapping_bodies():
				#We can handle more characters later
				player.sex_begin([body], "sex_goblin1")
				break
