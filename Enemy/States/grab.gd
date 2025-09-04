extends EnemyState


@onready var grab_collider : Area2D = $GrabCollider
var step_forward : bool

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0

	step_forward = data.get("step_forward", false)

func exit() -> void:
	enemy.catched_player = false

func update(delta: float) -> void:
	if enemy.catched_player:
		enemy.player.global_position.x = enemy.global_position.x + 24*enemy.facing

func _on_lunge_frame() -> void:
	if step_forward:
		enemy.move(enemy.move_speed/2.0, enemy.facing)
	else:
		enemy.move(enemy.move_speed/4.0, enemy.facing)
func _on_hit_frame() -> void:
	if grab_collider.has_overlapping_bodies():
		enemy.catched_player = true
		enemy.player.get_grabbed(enemy, "grab_goblin")
