extends Node


const SCRIPT_CONTENT = """
extends {extend_class}

func _make_custom_tooltip(_text:String) -> RichTextLabel:
	var label = preload("res://UI/custom_tooltip.tscn").instantiate()
	label.text = _text
	return label
"""


func _enter_tree() -> void:
	get_tree().node_added.connect(func(node:Node):
		# Skip nodes that aren't a control
		if not node is Control:
			return

		node = node as Control

		# Skip node if it does not have a tooltip
		if node.get_tooltip() == "":
			return

		# Get the class of the node
		var extend_class = node.get_class()
		# Also check if the node has a script
		var node_script = node.get_script() as Script
		if node_script:
			# If it does, then change it to extend that script
			extend_class = '"%s"' % node_script.resource_path

		# Format the script content
		var script_content = SCRIPT_CONTENT.format({"extend_class": extend_class})

		# Create a new script, assign the new source code and reload it
		var script = GDScript.new()
		script.source_code = script_content
		script.reload()
		# Set the new script to that node
		node.set_script(script)
	)
