extends EnemyState

var chase_dir := 0;

@onready var emote_timer : Timer = $EmoteTimer
var chatter_timer : Timer


func enter(previous_state_path:String, data := {}) -> void:
	chatter_timer = Timer.new()
	add_child(chatter_timer)
	chatter_timer.start(5)
	chatter_timer.one_shot = true

	enemy.emote_emitter.sprite.sprite_frames = preload("res://Resources/emote_lewd.tres")
	enemy.emote_emitter.stop()

func exit() -> void:
	enemy.emote_emitter.stop()
	chatter_timer.queue_free()
	enemy.emote_emitter.sprite.sprite_frames = preload("res://Resources/emote_all.tres")

func update(delta):
	var target = enemy.chase_target

	#Quit state
	if enemy.destructable_detector.has_overlapping_bodies():
		print("Colliding with a destructable")
		finished.emit("slash")
		return
	if !target:
		print("lose target from chase")
		enemy.lost_target()
		return
	# If dead or unconscious
	if enemy.dealth_finishing_blow && (target.unconscious || target.dead):
		print("target dead or unconscious")
		finished.emit("laugh")
		return
	# No line of sight
	if !enemy.target_in_sight:
		enemy.lost_target()
		return
	# Kalin having sex
	if target.is_in_state_group("sex_state"):
		finished.emit("leave_player")
		return
	if target.is_in_state_group("struggle_state"):
		enemy.update_animation("idle")
		enemy.velocity.x = 0
		return
	# Enemy in proximity
	if enemy.has_enemy_in_proximity():
		finished.emit("stance_walk", {"time" : 0.1, "backwards" : true})
		print("Has another enemy in it's proximity detector")
		return


	#region React to player
	if enemy.attack_detector.has_overlapping_bodies(): # If in combat range
		if target.hiding:
			# If Kalin hides in front of the enemy, unhide her
			target.force_unhide()
			finished.emit("grab")
		elif !target.dead && !target.unconscious:
			# Target is alive so take stance
			if target.can_be_attacked():
				finished.emit(enemy.main_stance.name)
			else:
				finished.emit("idle")
		elif target.unconscious && target.can_have_sex:
			# Allow player controller to play the sex animation
			enemy.update_animation("idle")
			enemy.velocity.x = 0
		return
	#endregion

	#If can move, play run animation, idle otherwise
	chase_dir = sign(enemy.chase_target.position.x - enemy.position.x)
	if enemy.move(enemy.chase_move_speed, chase_dir):
		enemy.update_animation("run")
	else:
		enemy.update_animation("idle")
		enemy.velocity.x = 0
		if chatter_timer.is_stopped():
			Ge.play_audio_from_string_array(enemy.global_position, -10, "res://SFX/Goblin/Chatter/")
			chatter_timer.start()
			enemy.play_chatter_emote()
