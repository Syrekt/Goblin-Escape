extends Interaction

@export var inert := true


signal activate
signal use

func _ready() -> void:
	activate.connect(_on_activate)
	use.connect(_on_use)

func update(player: Player) -> void:
	active = !inert
	if inert:
		return

	if Input.is_action_just_pressed("interact"):
		# Do something
		pass

func _on_activate() -> void:
	inert = false
	save()
func _on_use() -> void:
	pass

func save() -> void:
	Ge.save_node(self,{
		"inert": false,
	})
func load(data: Dictionary) -> void:
	inert = data.get(inert, true)
	if !inert:
		$Sprite.play("active")
