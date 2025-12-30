extends Interaction

@export var diary_owner : String
@export var diary_page : int

@onready var interaction_prompt : AnimatedSprite2D = find_child("InteractionPrompt")

func _ready() -> void:
	$AnimationPlayer.play("idle")


func update(player: Player) -> void:
	if Input.is_action_just_pressed("interact"):
		var game = Game.get_singleton()
		var _log = game.logs.get(diary_owner)
		if !_log:
			_log = {}

		print("diary_owner: "+str(diary_owner))
		print("diary_page: "+str(diary_page))
		_log.set(diary_page, true)
		game.logs.set(diary_owner, _log)
		queue_free()
