extends PlayerState

@onready var hitbox = get_child(0)
@onready var hitbox_collider = hitbox.get_node("Collider")

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.call_deferred("play", "stab")

func update(delta):
	if not player.is_on_floor():
		finished.emit("fall")

func exit():
	hitbox_collider.set_disabled(true)


func _on_stab_hitbox_body_entered(body: Node2D) -> void:
	print("body: "+str(body.name));
	Combat.deal_damage(player, body, 75)
