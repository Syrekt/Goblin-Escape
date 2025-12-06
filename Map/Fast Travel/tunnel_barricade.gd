class_name TunnelBarricade extends CharacterBody2D

var health : float

@onready var sprite := $BarricadeSprite

func _process(delta: float) -> void:
	Debugger.printui("sprite.frame: "+str(sprite.frame));
	Debugger.printui("health: "+str(health))

func take_damage(damage: int, source=null) -> void:
	# Play sfx and particle effects
	if damage > 0 && source:
		Ge.play_particle(load("res://VFX/crate_particles.tscn"), global_position)
		Ge.play_audio_from_string_array(source.global_position, 0, "res://SFX/Hit on wood/")

	health -= damage

	# Set frame
	var frame_count = float(sprite.sprite_frames.get_frame_count(sprite.animation))

	if health <= 0: # Break the barricade
		if damage > 0 && source:
			Ge.play_audio_free(0, "res://SFX/wood break.mp3")
		set_collision_layer_value(16, false)
		sprite.frame = frame_count
	else: # Update frame
		sprite.frame = (1 - (health / owner.barricade_health)) * (frame_count - 1)

	owner.save()
