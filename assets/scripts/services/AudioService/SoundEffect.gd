extends Resource
class_name SoundEffect

enum SOUND_EFFECT_TYPE {
	IDLE_MUSIC_1
}

@export var type: SOUND_EFFECT_TYPE
@export var sound_effect: AudioStreamMP3
@export_range(-40, 20) var volume = 0
