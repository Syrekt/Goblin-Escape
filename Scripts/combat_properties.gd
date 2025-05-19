extends Node

#region Stun
var stunned := false
@onready var stun_timer = $StunTimer

func stun(time := 2.0):
	stun_timer.start(time)
	stunned = true
	owner.state_node.state.finished.emit("stun")
	var tween = create_tween().bind_node(self).set_loops(6)
	tween.tween_property(owner.sprite, "offset", Vector2(-0.5, 0), 0.01)
	tween.tween_property(owner.sprite, "offset", Vector2(0.5, 0), 0.01)

func _on_stun_timer_timeout() -> void:
	stunned = false

#endregion
#region Pushback
var pushback_vector := Vector2.ZERO
@export var pushback_duration := 0.3
@onready var pushback_timer := 0.0
var pushback_elapsed_time := 0.0
@export var pushback_force := 100.0 #Used to test the system, not used in combat system


func pushback_apply(source_position: Vector2, strength: float) -> void:
	pushback_vector = (owner.global_position - source_position).normalized() * strength
	pushback_timer = pushback_duration
func pushback_reset() -> void:
	pushback_timer = 0;
	pushback_elapsed_time = 0;
	pushback_vector = Vector2.ZERO
#endregion
