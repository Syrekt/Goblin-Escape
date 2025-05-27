extends EnemyState

@onready var lead_timer : Timer = $LeadTimer
@onready var secondary_timer : Timer = $SecondaryTimer

var friend : Enemy

var animation_names

func enter(previous_state_path: String, data := {}) -> void:
	friend = enemy.friend
	enemy.call_deferred("update_animation", "idle")
	enemy.velocity.x = 0
	friend.set_facing(sign(enemy.global_position.x - friend.global_position.x))
	lead_timer.start()

	var frames = enemy.emote_emitter.sprite.sprite_frames
	animation_names = frames.get_animation_names()
func exit() -> void:
	enemy.friend = null
	enemy.chatting = false
	lead_timer.stop()
	secondary_timer.stop()

func update(delta: float) -> void:
	if enemy.chase_target:
		finished.emit("patrol")

func _on_lead_timer_timeout() -> void:
	var emote = animation_names[randi() % animation_names.size()]
	enemy.emote_emitter.play(emote)
	Ge.play_audio_from_string_array(enemy.global_position, -10, "res://SFX/Goblin/Chatter/")
	secondary_timer.start()


func _on_secondary_timer_timeout() -> void:
	var emote = animation_names[randi() % animation_names.size()]
	friend.emote_emitter.play(emote)
	Ge.play_audio_from_string_array(friend.global_position, -10, "res://SFX/Goblin/Chatter/")
	lead_timer.start()
