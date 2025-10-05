extends Interaction

@export var inert := true


signal activate
signal use

func _ready() -> void:
	activate.connect(_on_activate)
	use.connect(_on_use)

func _on_activate() -> void:
	pass
func _on_use() -> void:
	pass
