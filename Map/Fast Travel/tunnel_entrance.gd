class_name TunnelEntrance extends Interaction

@export var can_spawn_goblin := true

@export var target_entrance : TunnelEntrance
@export var barricaded := false
@export var barricade_health := 50

@onready var fade : ScreenFade = get_tree().current_scene.find_child("ScreenFade")

@onready var goblin := preload("res://Enemy/Goblin/goblin.tscn")
@onready var goblin_warrior := preload("res://Enemy/GoblinWarrior/goblin_warrior.tscn")

@onready var spawn_timer := $SpawnTimer
@onready var barricade := $Barricade

var fading := false

var player : Player

func _ready() -> void:
	if !barricaded: barricade.queue_free()
	else:			barricade.health = barricade_health

	var game = Game.get_singleton()
	await game.room_loaded
	var save_data = game.get_data_in_room(name)
	if save_data:
		load_data(save_data)
	
	if can_spawn_goblin:
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)



func update(_player: Player) -> void:
	player = _player


	if Input.is_action_just_pressed("interact"):
		if target_entrance.barricade && target_entrance.barricade.health >= 0:
			var thoughts = [
				"It's blocked on the other end.",
				"I should clear it's exit first.",
				"I don't want to get stuck in there.",
			]
			player.think(thoughts.pick_random())
		elif barricade && barricade.health > 0:
			var thoughts = [
				"I should destroy the barricade.",
				"The barricade’s blocking the way. I need to break it.",
				"I can’t get through unless I destroy that barricade.",
				"I’ll have to clear this blockade first.",
			]
			player.think(thoughts.pick_random())
		elif !barricade || (barricade && barricade.health <= 0):
			player.animation_player.play("crouch_walk")

			var tween = create_tween().bind_node(self)
			tween.tween_property(player, "global_position:x", global_position.x, 0.2).set_trans(Tween.TRANS_LINEAR)
			await tween.finished

			player.state_node.state.finished.emit("crawl_in")
			$CrawlSFX.play()

			await player.animation_player.animation_finished

			fade.fade_in_finished.connect(_on_fade_in_finished)
			fade.fade_out_finished.connect(_on_fade_out_finished)
			fade.fade_in()
			fading = true

func _on_fade_in_finished() -> void:
	player.global_position = target_entrance.global_position
	player.col_interaction.interact()
	fade.fade_out()
	fade.fade_in_finished.disconnect(_on_fade_in_finished)

func _on_fade_out_finished() -> void:
	player.state_node.state.finished.emit("crawl_out")
	target_entrance.spawn_timer.start(3.0)
	fade.fade_out_finished.disconnect(_on_fade_out_finished)


func save() -> void:
	var game = Game.get_singleton()
	game.save_data_in_room(name, {"barricade_health": barricade.health})
func load_data(data: Dictionary) -> void:
	print("Load tunnel data: "+str(data))
	if barricaded:
		if barricade:
			barricade.health = data.get("barricade_health", barricade_health)
			barricade.take_damage(0) # Update sprite
		else:
			printerr("Can't find barricade")
	else:
		barricade.queue_free()

func _on_spawn_timer_timeout() -> void:
	if randf() > 0.9:
		var enemy = [goblin, goblin_warrior].pick_random().instantiate()
		enemy.global_position = global_position
		enemy.assign_player(Game.get_singleton().player)
		add_sibling(enemy)
