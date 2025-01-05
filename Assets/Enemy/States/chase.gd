extends EnemyState

var chase_dir = 0;
var chase_target: Node2D

func enter(previous_state_path: String, data := {}) -> void:
	chase_target = enemy.chase_target


func update(delta):
	chase_dir = sign(chase_target.position.x - enemy.position.x)
	Debugger.printui(["Chase dir: ", chase_dir])
	if not %ChaseDetector.has_overlapping_bodies():
		print("Lost player")
		chase_target = null
		enemy.state_node.state.finished.emit("patrol")
	elif %AttackDetector.has_overlapping_bodies():
		print("Detected player")
		enemy.state_node.state.finished.emit("stance_light")

func physics_update(delta):
	enemy.move(chase_dir, delta)
