extends PlayerState

@onready var hitbox = get_child(0)
@onready var sfx_stab_hit = load("res://Assets/SFX/Kalin/stab1.wav")
@onready var sfx_stab_whiff = load("res://Assets/SFX/Kalin/Sword Woosh 12.wav")

@export var pushback_force := 100

var popup_scene = preload("res://Objects/text_pop_up.tscn")
var thought_scene = preload("res://Objects/thought.tscn")

signal attack_frame

func enter(previous_state_path: String, data := {}) -> void:
	player.call_deferred("update_animation", name)

func update(delta):
	if !player.is_on_floor():
		finished.emit("fall")

func _on_attack_frame() -> void:
	print("stab hit")
	if hitbox.has_overlapping_bodies():
		var defender = hitbox.get_overlapping_bodies()[0]
		if defender is Enemy:
			var defender_state = defender.state_node.state.name
			if defender_state == "stance_defensive":
				player.combat_properties.stun(2.0)
				Ge.play_audio_from_string_array(player.audio_emitter, 0, "res://Assets/SFX/Sword hit shield")
			else:
				defender.combat_properties.pushback_apply(player.global_position, pushback_force)
				defender.take_damage(player.stab_damage, player)
				player.play_sfx(sfx_stab_hit)
		else:
			defender.take_damage(0, player)
			print("Ineffective")
			var _text = popup_scene.instantiate()
			get_tree().current_scene.add_child(_text)
			_text.global_position = player.global_position - Vector2(0, 20)
			_text.label.text = "[color=yellow]Ineffective[/color]"
			var thought_container = player.find_child("ThoughtContainer")
			thought_container.push("I should hit it harder")
	else:
		player.play_sfx(sfx_stab_whiff)
