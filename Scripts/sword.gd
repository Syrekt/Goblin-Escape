extends Interaction

func _ready() -> void:
	$AnimationPlayer.play("idle")

func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		print("Do something")
