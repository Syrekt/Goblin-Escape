extends CanvasLayer

var confirmation_function : Callable
var rejection_function : Callable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_no_pressed() -> void:
	rejection_function.call()


func _on_yes_pressed() -> void:
	confirmation_function.call()
