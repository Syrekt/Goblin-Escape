extends PlayerState

@onready var hitbox = get_child(0)
@onready var hitbox_collider = hitbox.get_node("Collider")

var enemy_ignore_list := []

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "bash")
	enemy_ignore_list = []

func physics_update(delta: float) -> void:
	player.move(delta)

func update(delta):
	if not player.is_on_floor():
		finished.emit("fall")
	if player.sprite.frame == 3:
		player.velocity.x = 150 * player.facing

func exit():
	hitbox_collider.set_disabled(true)


func _on_bash_hitbox_body_entered(body: Node2D) -> void:
	if enemy_ignore_list.has(body): return

	print("body: "+str(body.name));
	Combat.deal_damage(player, body, 300)
	enemy_ignore_list.append(body)
