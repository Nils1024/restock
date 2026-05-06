extends Node2D

enum ButtonType {
	START,
	SETTINGS,
	QUIT
}

@onready var StartGameButton = $VBoxContainer/CenterContainer/VBoxContainer/StartGame

var current_button_type = null

func _ready() -> void:
	_set_text_to_language()
	
	$FadeTransition.show()
	$FadeTransition/AnimationPlayer.play("Fade_out")
	AudioService.create_audio(SoundEffect.SOUND_EFFECT_TYPE.IDLE_MUSIC_1)
	
func _set_text_to_language() -> void:
	StartGameButton.text = tr("PLAY")
	
func _on_start_game_pressed() -> void:
	current_button_type = ButtonType.START
	$FadeTransition.show()
	$FadeTransition/Timer.start()
	$FadeTransition/AnimationPlayer.play("Fade_in")


func _on_help_pressed() -> void:
	$HowToPlay.show()


func _on_settings_pressed() -> void:
	current_button_type = ButtonType.SETTINGS
	$FadeTransition.show()
	$FadeTransition/Timer.start()
	$FadeTransition/AnimationPlayer.play("Fade_in")


func _on_quit_game_pressed() -> void:
	current_button_type = ButtonType.QUIT
	$FadeTransition.show()
	$FadeTransition/Timer.start()
	$FadeTransition/AnimationPlayer.play("Fade_in")


func _on_timer_timeout() -> void:
	match current_button_type:
		ButtonType.START:
			get_tree().change_scene_to_file("res://assets/scenes/menus/save_selection_Menu.tscn")
		ButtonType.SETTINGS:
			get_tree().change_scene_to_file("res://assets/scenes/menus/settings_menu.tscn")
		ButtonType.QUIT:
			get_tree().quit()
