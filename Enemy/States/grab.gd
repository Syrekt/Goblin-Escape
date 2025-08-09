extends EnemyState

@onready var grab_collider : Area2D = $GrabCollider
@onready var struggle_position : Marker2D = $StrugglePosition

func enter(previous_state_path: String, data := {}) -> void:
	enemy.call_deferred("update_animation", name)
	enemy.velocity.x = 0


func _on_lunge_frame() -> void:
	enemy.move(enemy.move_speed/4.0, enemy.facing)
func _on_hit_frame() -> void:
	if grab_collider.has_overlapping_bodies():
		finished.emit("struggle")
		enemy.player.get_grabbed(enemy, enemy.global_position.x + struggle_position.position.x * enemy.facing)
