extends Control

func _make_custom_tooltip(text:String) -> Control:
	var tooltip = preload("res://UI/custom_tooltip.tscn").instantiate()
	var label = tooltip.find_child("Label")
	print("Tooltip Text: " + label.text)
	return tooltip
