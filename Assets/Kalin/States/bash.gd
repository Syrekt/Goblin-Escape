extends PlayerState

@onready var hitbox = get_child(0)
@onready var hitbox_collider = hitbox.get_node("Collider")
@onready var sfx_bash_hit = load("res://Assets/SFX/Kalin/punch1.wav")
@onready var sfx_bash = load("res://Assets/SFX/Kalin/kick_long_whoosh_19.wav")

var enemy_ignore_list := []

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)
	enemy_ignore_list = []
	player.set_collision_mask_value(4, true)
	player.play_sfx(sfx_bash)

func update(delta):
	if player.sprite.frame == 3:
		player.velocity.x = 150 * player.facing

func exit():
	player.set_collision_mask_value(4, false)


func _on_bash_hitbox_body_entered(body: Node2D) -> void:
	if enemy_ignore_list.has(body): return

	Combat.deal_damage(player, player.bash_damage, body, 300)
	enemy_ignore_list.append(body)
	player.play_sfx(sfx_bash_hit)
