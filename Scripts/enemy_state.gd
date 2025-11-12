class_name EnemyState extends State

var enemy: Enemy

func _ready():
	await owner.ready
	enemy = owner as Enemy
	assert(enemy != null, "The EnemState state type must be used only in the enemy scene. It needs the owner to be a Enemy node.")
