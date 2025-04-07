extends Node

func string_array_get_random(array: PackedStringArray) -> String:
	var i = randi() % array.size()
	return array[i]
func play_audio_from_string_array(emitter: AudioStreamPlayer2D, volume: float, path: String) -> void:
	if !DirAccess.dir_exists_absolute(path): push_error("Path <%s> doesn't exists!", path)
	var array = DirAccess.get_files_at(path)
	var sound = string_array_get_random(array)
	print("sound: "+str(sound))
	if sound.ends_with(".import"):
		sound = sound.get_basename()
	
	emitter.volume_db = volume
	emitter.stream = load(path + "/" + sound)
	emitter.play()
func play_audio(emitter: AudioStreamPlayer2D, volume: int, audio: AudioStream) -> void:
	emitter.volume_db = volume
	emitter.stream = audio
	emitter.play()
