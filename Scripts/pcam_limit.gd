extends Area2D


func _on_body_entered(body:Node2D) -> void:
	print("body.pcam.limit_target: "+str(body.pcam.limit_target));
	body.pcam.limit_target = get_child(0).get_path()


func _on_body_exited(body:Node2D) -> void:
	print("body: "+str(body));
	print("body.pcam: "+str(body.pcam));
	body.pcam.draw_limits = false
	body.pcam.limit_target = ""
