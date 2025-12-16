class_name Checkpoint extends Interaction

var save_effect_scene = load("res://VFX/save_effect.tscn")
var saved := false
var player : Player
@onready var upper_sprite := $UpperSprite
@onready var lower_sprite := $LowerSprite
@onready var fly_spawn_points := $SpawnPoints
@onready var rest_menu : PanelContainer = $CanvasLayer/RestMenu

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
#endregion


func update(_player : Player) -> void:
	player = _player
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
		
		Ge.play_audio_free(0, "res://SFX/water_splash1.wav")

		for node in get_children():
			if node.is_in_group("lights"):
				var tween := create_tween().bind_node(node)
				tween.tween_property(node, "color", Color(0.25, 0.3, 0.66, 1.0), 1)

		rest_menu.show()
		#Play some VFX and reset enemies

	if rest_menu.visible:
		if Input.is_action_just_pressed("back"):
			player.character_panel.hide()
			rest_menu.hide()


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
	player.character_panel.hide()
	rest_menu.hide()
#endregion
