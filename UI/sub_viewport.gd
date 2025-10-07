extends SubViewport

var player : Player
var offset := Vector2(0, 0)
var drag_offset := Vector2(0, 0)

func _ready() -> void:
	world_2d = get_tree().root.world_2d
	player = Ge.player
	size = get_viewport().size
	if player:
		$Camera2D.global_position = player.global_position
	$Camera2D.anchor_mode = $Camera2D.ANCHOR_MODE_DRAG_CENTER

func _physics_process(delta: float) -> void:
	if !player:
		return
