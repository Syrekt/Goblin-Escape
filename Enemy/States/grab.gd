extends EnemyState


@onready var grab_collider : Area2D = $GrabCollider
var step_forward := false

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0

	if enemy.position.distance_to(enemy.chase_target.position) > 32:
		step_forward = true

func exit() -> void:
	enemy.catched_player = false

func update(delta: float) -> void:
	if enemy.velocity.y != 0:
		finished.emit("idle")
	if enemy.catched_player:
		enemy.player.global_position.x = enemy.global_position.x + 24*enemy.facing

func _on_lunge_frame() -> void:
	if step_forward:
		enemy.apply_force_x(100, 0.5)
	else:
		enemy.apply_force_x(50, 0.5)
func _on_hit_frame() -> void:
	if !enemy.player.can_be_attacked():
		return
	if grab_collider.has_overlapping_bodies():
		var can_be_attacked = enemy.player.can_be_attacked()
		if enemy.player.health.value > 0:
			enemy.catched_player = true
			enemy.player.get_grabbed(enemy, "grab_goblin")
