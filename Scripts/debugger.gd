extends CanvasLayer

var gui_log := " "
@onready var label = $Control/Label

#func printui(args : Array):
	#for text in args:
	#	gui_log += str(text)

	#gui_log += "\n"

func printui(text : String):
	gui_log += text + "\n"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = gui_log
	gui_log = ""
