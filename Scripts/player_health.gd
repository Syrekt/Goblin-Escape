extends StatBar

@onready var fmod_heartbeat : FmodEventEmitter2D = $Heartbeat
@onready var health_vignette : ColorRect = $"../../../../Overlays/HealthVignette"

var health_vignette_tween : Tween

@export var regeneration_speed := 0.01

var tween : Tween
var tint_under_tween	: Tween
var tint_over_tween		: Tween
var tint_progress_tween : Tween
var tint_tween : Tween
var faded := false

var low_health_tween := false
var high_health_tween := false

@export var fade_out_col : Color = Color(0.125, 0.125, 0.125, 0.0)
@export var vignette_max_radius := 0.4

const TINT_KALIN	= Color.RED
const TINT_SPRITE	= Color.RED

func _process(delta: float) -> void:
	var final_regeneration_speed = regeneration_speed

	if !owner.dead && !owner.unconscious:
		value += final_regeneration_speed * delta

#	if !faded && final_regeneration_speed > regeneration_speed:
#		if !tint_under_tween:
#			tint_under_tween = create_tween().bind_node(self)
#			tint_under_tween.set_loops(-1)
#			tint_under_tween.tween_property(self, "tint_under", Color.GREEN, 1.0)
#			tint_under_tween.tween_property(self, "tint_under", Color.WHITE, 1.0)
#	elif tint_under_tween:
#		tint_under_tween.kill()
#		tint_under_tween = null

func fade_out() -> void:
	faded = true

	if tint_tween		: tint_tween.kill()

	tint_tween = create_tween().bind_node(self)
	tint_tween.tween_property(self, "tint_over", fade_out_col, 1.0)
	#tint_tween.chain().tween_property(self, "tint_under", fade_out_col, 1.0)
	#tint_tween.chain().tween_property(self, "tint_progress", fade_out_col, 1.0)


func fade_in() -> void:
	faded = false

	if tint_tween		: tint_tween.kill()

	tint_tween = create_tween().bind_node(self)
	tint_tween.tween_property(self, "tint_over", Color.WHITE, 1.0)
	#tint_tween.chain().tween_property(self, "tint_under", Color.WHITE, 1.0)
	#tint_tween.chain().tween_property(self, "tint_progress", Color.WHITE, 1.0)


func _on_update_health_timer_timeout() -> void:
	var game = Game.get_singleton()
	FmodServer.set_global_parameter_by_name("Health", value / 100.0)
	if value <= max_value * 0.25 && !low_health_tween:
		low_health_tween	= true
		high_health_tween	= false
		fmod_heartbeat.play(false)

		health_vignette.show()


		if !health_vignette_tween:
			health_vignette_tween = create_tween().bind_node(health_vignette)
			health_vignette_tween.finished.connect(update_tween)
			health_vignette_tween.tween_property(health_vignette.material, "shader_parameter/outer_radius", 2.0 - vignette_max_radius * (1 - (value / (max_value*0.25))), 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			health_vignette_tween.tween_property(health_vignette.material, "shader_parameter/outer_radius", 2.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	elif value > max_value * 0.25 && !high_health_tween:
		$Exhaustion.play()
		high_health_tween	= true
		low_health_tween	= false
		fmod_heartbeat.stop()

		if health_vignette_tween:
			health_vignette_tween.kill()
			health_vignette_tween = null
		var _tween = create_tween().bind_node(health_vignette)
		_tween.tween_property(health_vignette.material, "shader_parameter/outer_radius", 3.0, 0.1)
		_tween.tween_callback(health_vignette.hide)
	

func update_tween() -> void:
	health_vignette_tween.stop()
	health_vignette_tween.tween_property(health_vignette.material, "shader_parameter/outer_radius", 2.0 - vignette_max_radius * (1 - (value / (max_value*0.25))), 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	health_vignette_tween.tween_property(health_vignette.material, "shader_parameter/outer_radius", 2.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	health_vignette_tween.play()
