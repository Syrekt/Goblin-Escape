class_name ScreenFade extends CanvasLayer

var tween : Tween
@onready var color_rect : ColorRect = $ColorRect
@onready var player : Player = get_tree().current_scene.find_child("Kalin")
var tween_finished := false
enum FadeMode {IN, OUT}
var fade_mode : FadeMode

signal fade_in_finished
signal fade_out_finished

func fade_in(time := 1.0) -> void:
	fade_mode = FadeMode.IN

	tween_finished = false

	tween = create_tween().bind_node(self)
	tween.tween_property(color_rect, "color", Color(0.0, 0.0, 0.0, 1.0), time)
	player.ui.fade_out(time)

	await tween.finished
	await get_tree().create_timer(0.2).timeout
	tween_finished = true

	fade_in_finished.emit()

func fade_out(time := 1.0) -> void:
	fade_mode = FadeMode.OUT

	tween_finished = false
	await get_tree().create_timer(1.0).timeout

	tween = create_tween().bind_node(self)
	tween.tween_property(color_rect, "color", Color(0.0, 0.0, 0.0, 0.0), time)
	player.ui.fade_in(time)

	await tween.finished
	tween_finished = true

	fade_out_finished.emit()
