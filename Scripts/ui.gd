extends CanvasLayer

@onready var modulator : CanvasModulate = $UITint
@onready var health : TextureProgressBar = find_child("Health")

var tween_low_health : Tween

func _ready() -> void:
	tween_low_health = create_tween().bind_node(self)
	tween_low_health.tween_property(modulator, "color", Color(1.0, 0.0, 0.0, 1.0), 1.0)
	tween_low_health.tween_property(modulator, "color", Color(1.0, 1.0, 1.0, 1.0), 1.0)
	tween_low_health.set_loops(-1)
	tween_low_health.pause()

func fade_in(time := 1.0) -> void:
	var tween_ui = create_tween().bind_node(self)
	tween_ui.tween_property(modulator, "color", Color(1.0, 1.0, 1.0, 1.0), time)

	_on_update_health_timer_timeout()

func fade_out(time := 1.0) -> void:
	var tween_ui = create_tween().bind_node(self)
	tween_ui.tween_property(modulator, "color", Color(1.0, 1.0, 1.0, 0.0), time)

	if tween_low_health:
		tween_low_health.pause()


func _on_update_health_timer_timeout() -> void:
	if health.value <= health.max_value * 0.25:
		tween_low_health.play()
	else:
		tween_low_health.pause()
		create_tween().tween_property(modulator, "color", Color.WHITE, 1.0)
