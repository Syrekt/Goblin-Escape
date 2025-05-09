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
func play_audio(emitter: AudioStreamPlayer2D, volume: int, audio_path: String) -> void:
	emitter.volume_db = volume
	emitter.stream = load(audio_path)
	emitter.play()
func play_audio_free(volume: int, audio_path: String) -> void:
	var player = AudioStreamPlayer.new()
	add_sibling(player)

	player.volume_db = volume
	player.stream = load(audio_path)
	player.finished.connect(player.queue_free)
	player.play()
func EmitNoise(position: Vector2, amount: float) -> void:
	var noise = load("res://Objects/noise.tscn").instantiate()
	get_tree().current_scene.add_child(noise)

	noise.amount_max = amount
	noise.position = position
