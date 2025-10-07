extends Interaction

@export var inert := true
var map_icon := "portal"


func update(player: Player) -> void:
	active = !inert

	if Input.is_action_just_pressed("interact"):
		if inert:
			activate()
		else:
			print("Teleport")
			pass

	if inert:
		return

func activate() -> void:
	inert = false
	$Light.enabled = true
	$Sprite.play("active")
	save()
func use() -> void:
	pass

func save() -> void:
	Ge.save_node(self,{
		"inert": false,
	})
func load(data: Dictionary) -> void:
	inert = data.get(inert, true)
	if !inert:
		$Sprite.play("active")
		$Light.enabled = true
