extends EnemyState

var path = "res://Assets/SFX/Goblin/Death"
@onready var files = DirAccess.get_files_at(path)

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", "death")
	enemy.states_locked = true
	enemy.velocity = Vector2.ZERO
	Ge.play_audio_from_string_array(enemy.audio_emitter, -10, path, files)
