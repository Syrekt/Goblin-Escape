extends Control

func _process(delta: float) -> void:
	var ui_nodes = get_tree().get_nodes_in_group("FullscreenPanel")
	var fullscreen_panel_open := false
	for node in ui_nodes:
		if node.visible:
			fullscreen_panel_open = true
			break
	
	if visible:
		if fullscreen_panel_open:
			hide()
	else:
		if !fullscreen_panel_open:
			show()

	$Scaled.scale = Vector2(Options.hud_scale, Options.hud_scale)
