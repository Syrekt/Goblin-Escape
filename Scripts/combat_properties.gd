extends Node


#region Stun
var stunned := false
@onready var stun_timer = $StunTimer

@export var stun_time : float

func stun(time := 2.0):
	stun_timer.start(time)
	stunned = true
	owner.state_node.state.finished.emit("stun")

func _on_stun_timer_timeout() -> void:
	stunned = false
#endregion
#region Pushback
var pushback_vector := Vector2.ZERO
var pushback_duration := 0.3
var pushback_timer := 0.0
var pushback_elapsed_time := 0.0


func pushback_apply(source_position, strength) -> void:
	pushback_vector = (owner.global_position - source_position).normalized() * strength
	pushback_timer = pushback_duration
#endregion
