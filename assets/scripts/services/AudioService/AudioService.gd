extends Node2D

var sound_effect_dict: Dictionary = {}

@export var sound_effects: Array[SoundEffect]

func _ready() -> void:
	for sound_effect: SoundEffect in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect

func create_2d_audio_at_location(location: Vector2i, type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var new_2d_audio: AudioStreamPlayer2D = _create_audio_stream_player_object(sound_effect_dict[type])
		new_2d_audio.position = location
		new_2d_audio.play()
	else:
		push_warning("AudioService - Failed to find audio for: ", type)
	
func create_audio(type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var new_2d_audio: AudioStreamPlayer2D = _create_audio_stream_player_object(sound_effect_dict[type])
		new_2d_audio.play()
	else:
		push_warning("AudioService - Failed to find audio for: ", type)
	
func _create_audio_stream_player_object(sound_effect: SoundEffect) -> AudioStreamPlayer2D:
	var new_2d_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	add_child(new_2d_audio)
	new_2d_audio.stream = sound_effect.sound_effect
	new_2d_audio.volume_db = sound_effect.volume
	new_2d_audio.finished.connect(new_2d_audio.queue_free)
	return new_2d_audio
