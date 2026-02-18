class_name Checkpoint extends Interaction

var save_effect_scene = load("res://VFX/save_effect.tscn")
var saved := false
var player : Player
@onready var upper_sprite := $UpperSprite
@onready var lower_sprite := $LowerSprite
@onready var fly_spawn_points := $SpawnPoints
@onready var rest_menu : PanelContainer = $CanvasLayer/RestMenu
@onready var fountain_sound_emitter : FmodEventEmitter2D = $FountainSound
@onready var water_splash_emitter : FmodEventEmitter2D = $WaterSplash

var fly_scene = preload("res://Others/fly_1.tscn")
var timer : Timer

func _ready() -> void:
	rest_menu.hide()
	print("Checkpoint ready")
#region VFX lights
	for node in get_children():
		if node.is_in_group("lights"):
			node.color = Color(0, 0, 0, 0)
	timer = Timer.new()
	timer.timeout.connect(spawn_fly)
	add_child(timer)
	timer.start(randf_range(5, 10))
	player = Game.get_singleton().player
#endregion

func _process(delta: float) -> void:
	fountain_sound_emitter.set_parameter("Distance", position.distance_to(player.position))

func update(_player : Player) -> void:
	#$CanvasLayer.layer = 10
	if player.pressed("interact"):
		player.smell.value = 0
		player.smell.dirt_amount = 0
		player.arousal.value = 0
		player.fatigue.value = 0
		player.health.value = player.health.max_value
		player.status_effect_container.rest()

		var game = Game.get_singleton()
		game.world_refreshed.emit()
		game.checkpoint = {
			"name": name,
			"room": game.map.name,
		}

		game.save_game()
		upper_sprite.play("save")

		var save_effect : AnimatedSprite2D = save_effect_scene.instantiate()
		save_effect.animation_finished.connect(save_effect.queue_free)
		player.add_child(save_effect)
		player.think("I should be safe now..")
		
		water_splash_emitter.play()

		for node in get_children():
			if node.is_in_group("lights"):
				var tween := create_tween().bind_node(node)
				tween.tween_property(node, "color", Color(0.25, 0.3, 0.66, 1.0), 1)

		rest_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#Play some VFX and reset enemies

	if rest_menu.visible:
		if Input.is_action_just_pressed("back"):
			_on_leave_pressed()


#region Methods
func spawn_fly() -> void:
	var fly	= fly_scene.instantiate()
	var child_count = fly_spawn_points.get_child_count()
	#print("child_count: "+str(child_count))
	var spawn_point = fly_spawn_points.get_child(randi() % child_count)
	#print("spawn_point: "+str(spawn_point))
	fly.global_position = spawn_point.global_position
	fly.checkpoint = self
	add_child(fly)
#endregion
#region Signals
func _on_level_up_pressed() -> void:
	player.toggle_character_panel()

func _on_leave_pressed() -> void:
	if player.character_panel.has_unconfirmed_changes:
		player.lvl_close_confirmation.show()
		player.lvl_close_confirmation.checkpoint = self
	else:
		player.character_panel.hide()
		rest_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
#endregion
