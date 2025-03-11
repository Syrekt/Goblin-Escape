extends PlayerState

@export var is_on_attack_frame := false

@onready var hitbox = get_child(0)
@onready var sfx_slash_hit = load("res://Assets/SFX/HIT 01.wav")
@onready var sfx_slash_whiff = load("res://Assets/SFX/Heavy sword woosh 11.wav")

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", "slash")
	player.velocity.x = 0;

func update(delta):
	if !player.is_on_floor():
		finished.emit("fall")
	if is_on_attack_frame:
		if hitbox.has_overlapping_bodies():
			var body = hitbox.get_overlapping_bodies()[0]
			Combat.deal_damage(player, body, 100)
			player.play_sfx(sfx_slash_hit)
		else:
			player.play_sfx(sfx_slash_whiff)
			pass

func _on_slash_hitbox_body_entered(body: Node2D) -> void:
	Combat.deal_damage(player, body, 100)
