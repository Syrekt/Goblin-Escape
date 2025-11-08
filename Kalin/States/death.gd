extends PlayerState

@onready var recovery_timer : Timer = $RecoveryTimer
@onready var sex_timer : Timer = $SexTimer
@onready var participant_collider : Area2D = $SexParticipantCollider
@onready var death_timer : Timer = $DeathTimer
@onready var death_screen : CanvasLayer = $"../../../DeathScreen"


func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	player.velocity.x = 0
	var source = data.get("source")

	if !source:
		player.dead = true
		player.unconscious = false
	else:
		for buff in player.buff_container.get_children():
			if buff.effect == "death's door":
				player.dead = true
				player.unconscious = false
				buff.queue_free()
				break

	if player.dead:
		print("Dead")
		death_timer.start()
		print("death_timer.time_left: "+str(death_timer.time_left));
	else:
		print("Unconscious")
		player.unconscious = true
		sex_timer.start()
		recovery_timer.start()
		print("recovery_timer.time_left: "+str(recovery_timer.time_left));

func exit() -> void:
	recovery_timer.stop()
	sex_timer.stop()
	death_timer.stop()

func send_player() -> void:
	player.health.value = player.health.max_value
	player.dead = false
	player.experience.drop_experience()
	finished.emit("get_up")
	
	var game = Game.get_singleton()
	if game.checkpoint:
		var checkpoint_data = game.checkpoint
		game.load_room(checkpoint_data.room + ".tscn")
		await game.room_loaded
		var checkpoint = game.map.find_child(checkpoint_data.name)
		player.position = checkpoint.position


func update(delta: float) -> void:
	if player.dead:
		if death_timer.is_stopped():
			if !death_screen.visible:
				player.controls_disabled = true
				player.ui.fade_out(1)

				var color_rect	= death_screen.find_child("ColorRect")
				var label		= death_screen.find_child("RichTextLabel")

				death_screen.show()
				var tween_rect	: Tween = create_tween().bind_node(self)
				tween_rect.tween_property(color_rect, "color", Color(0.0, 0.0, 0.0, 1.0), 1)
				await tween_rect.finished

				#var tween_label = create_tween().bind_node(self)
				#tween_label.tween_property(label, "theme_override_colors/default_color", Color(1.0, 0.0, 0.0, 1.0), 1)
				#await tween_label.finished

				await get_tree().create_timer(1.0).timeout
				send_player()

				#tween_label = create_tween().bind_node(self)
				#tween_label.tween_property(label, "theme_override_colors/default_color", Color(1.0, 0.0, 0.0, 0.0), 1)
				#await tween_label.finished

				tween_rect = create_tween().bind_node(self)
				tween_rect.tween_property(color_rect, "color", Color(0.0, 0.0, 0.0, 0.0), 1)

				player.ui.fade_in(1)

				await tween_rect.finished

				player.controls_disabled = false
				death_screen.hide()
				#player.ui.show()


func _on_recovery_timer_timeout() -> void:
	print("Recovery timer timeout")
	finished.emit("recover")


func _on_sex_timer_timeout() -> void:
	print("Sex timer timeout")
	player.can_have_sex = true
	if participant_collider.has_overlapping_bodies():
		for body in participant_collider.get_overlapping_bodies():
			#We can handle more characters later
			player.sex_begin([body], "lose_sex_goblin1")
			break
