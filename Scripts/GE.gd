extends Node

func string_array_get_random(array: PackedStringArray) -> String:
	var i = randi() % array.size()
	return array[i]

func play_audio_from_string_array(emitter: AudioStreamPlayer2D, volume: int, path: String, array: PackedStringArray) -> void:
	var sound = string_array_get_random(array)
	if sound.ends_with(".import"):
		sound = sound.get_basename()
	
	emitter.volume_db = volume
	emitter.stream = load(path + "/" + sound)
	emitter.play()
