class_name TunnelBarricade extends CharacterBody2D

var health : float

func take_damage(damage: int, source) -> void:
	print("damage: "+str(damage))
	if damage > 0:
		Ge.play_particle(load("res://VFX/crate_particles.tscn"), global_position)
	health -= damage
	if health <= 0:
		Ge.play_audio_free(0, "res://SFX/wood break.mp3")
		owner.barricaded = false
	else:
		Ge.play_audio_from_string_array(source.global_position, 0, "res://SFX/Hit on wood/")
	print("health: "+str(health))
