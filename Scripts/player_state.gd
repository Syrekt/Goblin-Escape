class_name PlayerState extends State

var player: Player
var lock_stance_button:= false

func _ready():
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
