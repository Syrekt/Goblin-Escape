class_name TunnelEntrance extends Interaction

@export var target_entrance : TunnelEntrance
@export var barricaded := false
@export var barricade_health := 50

@onready var fade : CanvasLayer = get_tree().current_scene.find_child("ScreenFade")


var fading := false

var player : Player

func _ready() -> void:
	$BarricadeCollider.health = barricade_health

func update(_player: Player) -> void:
	player = _player
	if Input.is_action_just_pressed("interact"):
		if target_entrance.barricaded:
			var thoughts = [
				"It's blocked on the other end.",
				"I should clear the exit first.",
				"I don't want to get stuck in there.",
			]
			player.think(thoughts.pick_random())
		elif barricaded:
			var thoughts = [
				"I should destroy the barricade.",
				"The barricade’s blocking the way. I need to break it.",
				"I can’t get through unless I destroy that barricade.",
				"I’ll have to clear this blockade first.",
			]
			player.think(thoughts.pick_random())
		else:
			fade.fade_in()
			player.state_node.state.finished.emit("crawl_in")
			create_tween().tween_property(player, "global_position:x", global_position.x, 0.2).set_trans(Tween.TRANS_LINEAR)
			fading = true

func _process(delta: float) -> void:
	$BarricadeCollider.set_collision_layer_value(16, barricaded)
	if fading && player:
		if fade.tween_finished:
			player.global_position = target_entrance.global_position
			player.state_node.state.finished.emit("crawl_out")
			player.col_interaction.interact()
			fade.fade_out()
			fading = false

func save() -> void:
	Ge.save_node(self, {
		"barricaded"	: barricaded,
	})
func load(data: Dictionary) -> void:
	var value = data.get("barricaded")
	print(name + " value(barricaded): "+str(value))
	if value:
		barricaded = value
