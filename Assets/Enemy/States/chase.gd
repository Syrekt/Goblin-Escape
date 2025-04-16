extends EnemyState

var chase_dir := 0;
var chase_target: Node2D

func enter(previous_state_path: String, data := {}) -> void:
	chase_target = enemy.chase_target


func update(delta):
	#If can move, play run animation, idle otherwise
	chase_dir = sign(chase_target.position.x - enemy.position.x)
	if enemy.move(enemy.move_speed, chase_dir):
		enemy.animation_player.play("run")
	else:
		enemy.animation_player.play("idle")

	#Check line of sight for collisions
	enemy.line_of_sight.target_position = enemy.line_of_sight.to_local(chase_target.global_position)
	var collider_id = enemy.line_of_sight.get_collider()
	if collider_id != null:
		print("Patrol1")
		print("collider_id.name: "+str(collider_id.name));
		enemy.state_node.state.finished.emit("patrol")

	#Check if player is still within the chase collider
	if !%ChaseDetector.has_overlapping_bodies():
		chase_target = null
		print("Patrol2")
		enemy.state_node.state.finished.emit("patrol")
	elif %AttackDetector.has_overlapping_bodies():
		if chase_target.state_node.state.name != "death":
			finished.emit("stance_light")
