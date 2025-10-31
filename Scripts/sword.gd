extends Interaction

@export var objectives : Array[Objective]

func _ready() -> void:
	$AnimationPlayer.play("idle")

func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		player.has_sword = true
		queue_free()

func _notification(what: int) -> void:
	if what == NOTIFICATION_EXIT_TREE:
		for objective in objectives:
			print("show objective %s" %objective.name)
			objective.active = true
