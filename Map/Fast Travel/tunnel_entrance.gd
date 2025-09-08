class_name TunnelEntrance extends Interaction

@export var target_entrance : TunnelEntrance

@onready var fade : CanvasLayer = get_tree().current_scene.find_child("ScreenFade")

var fading := false

var player : Player


func update(_player: Player) -> void:
	player = _player
	if Input.is_action_pressed("interact"):
		fade.fade_in()
		player.state_node.state.finished.emit("crawl_in")
		create_tween().tween_property(player, "global_position:x", global_position.x, 0.2).set_trans(Tween.TRANS_LINEAR)
		fading = true

func _process(delta: float) -> void:
	if fading && player:
		if fade.tween_finished:
			player.global_position = target_entrance.global_position
			player.state_node.state.finished.emit("crawl_out")
			player.col_interaction.interact()
			fade.fade_out()
			fading = false
