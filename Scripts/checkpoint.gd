extends Interaction

var save_effect_scene = load("res://VFX/save_effect.tscn")
var saved := false
@onready var upper_sprite := $UpperSprite
@onready var lower_sprite := $LowerSprite
@onready var fly_spawn_points := $SpawnPoints

var fly_scene = preload("res://Scripts/fly.gd")

func _ready() -> void:
	for node in get_children():
		if node.is_in_group("lights"):
			node.color = Color(0, 0, 0, 0)
	spawn_fly()
	spawn_fly()
	spawn_fly()
	spawn_fly()
	spawn_fly()
	spawn_fly()
	spawn_fly()

func update(player: Player):
	if Input.is_action_just_pressed("interact"):
		Ge.save_game("save1")
		player.smell.value = 0
		player.smell.dirt_amount = 0
		player.arousal.value = 0

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


func spawn_fly() -> void:
	var fly	= fly_scene.new()
	var child_count = fly_spawn_points.get_child_count()
	#print("child_count: "+str(child_count))
	var spawn_point = fly_spawn_points.get_child(randi() % child_count)
	#print("spawn_point: "+str(spawn_point))
	fly.global_position = spawn_point.global_position
	fly.checkpoint = self
	add_child(fly)
