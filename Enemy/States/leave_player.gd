extends EnemyState

var move_dir : int
@onready var player : Player = get_node("/root/Game/Kalin")

func enter(previous_state_path : String, data := {}) -> void:
	enemy.call_deferred("update_animation", "run");
	move_dir = sign(enemy.global_position.x - player.global_position.x)
	$Timer.start()
func update(delta : float) -> void:
	if !enemy.move(enemy.patrol_move_speed, move_dir):
		enemy.patrol_amount = 2
		finished.emit("idle")


func _on_timer_timeout() -> void:
	enemy.patrol_amount = 2
	finished.emit("idle")
