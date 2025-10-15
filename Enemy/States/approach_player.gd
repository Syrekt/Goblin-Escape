extends EnemyState

func exit() -> void:
	enemy.velocity.x = 0 #Just in case

func update(delta: float) -> void:
	if enemy.chase_target.unconscious:
		var dist = abs(enemy.chase_target.global_position.x - enemy.global_position.x)
		var chase_dir = sign(enemy.chase_target.position.x - enemy.position.x)
		if dist > 32 && enemy.move(enemy.chase_move_speed, chase_dir):
			enemy.update_animation("run")
		else:
			enemy.update_animation("idle")
			enemy.velocity.x = 0
	else:
		finished.emit("idle")
