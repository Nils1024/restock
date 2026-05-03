extends Node2D

var sound_effect_dict: Dictionary = {}

@export var sound_effects: Array[SoundEffect]

func _ready() -> void:
	for sound_effect: SoundEffect in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect


func create_2d_audio_at_location(location: Vector2i, type: SoundEffect.SOUND_EFFECT_TYPE, auto_restart: bool = false) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		var new_2d_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child(new_2d_audio)
		new_2d_audio.position = location
		new_2d_audio.stream = sound_effect.sound_effect
		new_2d_audio.volume_db = sound_effect.volume
		new_2d_audio.set_meta("type", type)
		
		if auto_restart:
			new_2d_audio.finished.connect(new_2d_audio.play)
		else:
			new_2d_audio.finished.connect(new_2d_audio.queue_free)
		new_2d_audio.play()
		
	else:
		push_warning("AudioService - Failed to find audio for: ", type)


func create_audio(type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(new_audio)
		new_audio.stream = sound_effect.sound_effect
		new_audio.volume_db = sound_effect.volume
		new_audio.set_meta("type", type)
		new_audio.finished.connect(new_audio.queue_free)
		new_audio.play()
	else:
		push_warning("AudioService - Failed to find audio for: ", type)

func stop_audio(type: SoundEffect.SOUND_EFFECT_TYPE, fade_out: bool = false, duration: float = 0.5) -> void:
	for child in get_children():
		if (child is AudioStreamPlayer or child is AudioStreamPlayer2D) and child.get_meta("type") == type:
			if fade_out:
				var tween: Tween = create_tween()
				tween.tween_property(child, "volume_db", -80.0, duration)
				tween.tween_callback(child.queue_free)
			else:
				child.queue_free()
