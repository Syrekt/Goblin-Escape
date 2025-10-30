extends Area2D

@onready var pcam : PhantomCamera2D = $PhantomCamera2D

func _ready() -> void:
	for node in get_children():
		if node is CollisionShape2D:
			pcam.limit_target = node.get_path()

	var entered_connected = body_entered.is_connected(_on_body_entered)
	var exited_connected = body_exited.is_connected(_on_body_exited)
	print("entered_connected: "+str(entered_connected))
	print("exited_connected: "+str(exited_connected))


func _on_body_entered(body:Node2D) -> void:
	print("Body entered pcam region")
	pcam.set_follow_target(body)
	pcam.set_priority(20)
	pcam.follow_mode = PhantomCamera2D.FollowMode.GROUP
	pcam.follow_damping = true
	body.pcam = pcam


func _on_body_exited(body:Node2D) -> void:
	print("Body exited pcam region")
	pcam.set_priority(0)
	pcam.set_follow_target(null)
	body.pcam = pcam
