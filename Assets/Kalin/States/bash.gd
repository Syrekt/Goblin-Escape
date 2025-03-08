extends PlayerState

@onready var hitbox = get_child(0)
@onready var hitbox_collider = hitbox.get_node("Collider")

var enemy_ignore_list := []

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "bash")
	enemy_ignore_list = []

func update(delta):
	if player.sprite.frame == 3:
		player.velocity.x = 150 * player.facing

func exit():
	hitbox_collider.set_disabled(true)


func _on_bash_hitbox_body_entered(body: Node2D) -> void:
	if enemy_ignore_list.has(body): return

	print("body: "+str(body.name));
	Combat.deal_damage(player, body, 300)
	enemy_ignore_list.append(body)
