extends Interaction

@export_multiline var text : String

@onready var book : CanvasLayer = $Book
@onready var interaction_prompt : AnimatedSprite2D = find_child("InteractionPrompt")

func _ready() -> void:
	var label : RichTextLabel = book.find_child("RichTextLabel")
	label.text = text
	$AnimationPlayer.play("idle")
	$Book.visible = false


func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		book.visible = !book.visible
		if book.visible:
			interaction_prompt._show()
		else:
			interaction_prompt._hide()
