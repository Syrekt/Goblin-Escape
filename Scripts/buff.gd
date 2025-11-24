class_name StatusEffect extends Node

var value : float
var effect : String

func setup(_name:String,_value:float,_time:float) -> void:
	# Give -1 for infinite timer

	name = _name
	value = _value

	if _time == -1:
		$Timer.start(1)
		$Timer.paused = true
	else:
		$Timer.start(_time)


func _on_timer_timeout() -> void:
	queue_free()
