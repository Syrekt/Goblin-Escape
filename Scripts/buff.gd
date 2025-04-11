class_name Buff extends Node

var value : float

func setup(_value : float, _time : float) -> void:
	value = _value
	$Timer.start(_time)


func _on_timer_timeout() -> void:
	queue_free()
