extends EnemyState

var chase_dir = 0;
var chase_target: Node2D

func enter(previous_state_path: String, data := {}) -> void:
	chase_target = enemy.chase_target


func update(delta):
	chase_dir = sign(chase_target.position.x - enemy.position.x)
	if enemy.move(enemy.move_speed, chase_dir):
		enemy.animation_player.play("run")
	else:
		enemy.animation_player.play("idle")

	enemy.line_of_sight.target_position = enemy.line_of_sight.to_local(chase_target.global_position)
	var collider_id = enemy.line_of_sight.get_collider()
	if collider_id != null:
		enemy.state_node.state.finished.emit("patrol")

	if !%ChaseDetector.has_overlapping_bodies():
		chase_target = null
		enemy.state_node.state.finished.emit("patrol")
	elif %AttackDetector.has_overlapping_bodies():
		enemy.state_node.state.finished.emit("stance_light")
