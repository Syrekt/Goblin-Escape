extends Area2D


@onready var player : Player = get_node("/root/Game/Kalin")

func _ready() -> void:
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)

func _body_entered(body: Player) -> void:
	body.ladder = self
func _body_exited(body: Player) -> void:
	if body.ladder == self:
		body.ladder = null
