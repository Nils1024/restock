extends Node2D

enum ButtonType {
	BACK
}

var current_button_type = null

func _ready() -> void:
	LocalizationService.connect("language_changed", Callable(self, "_on_language_changed"))
	_set_text_to_language()
	
	$FadeTransition.show()
	$FadeTransition/AnimationPlayer.play("Fade_out")
	
func _set_text_to_language() -> void:
	# TODO
	$Control/Back.text = "Back"

func _on_button_pressed() -> void:
	current_button_type = ButtonType.BACK
	$FadeTransition.show()
	$FadeTransition/Timer.start()
	$FadeTransition/AnimationPlayer.play("Fade_in")

func _on_timer_timeout() -> void:
	match current_button_type:
		ButtonType.BACK:
			get_tree().change_scene_to_file("res://assets/scenes/menus/main_menu.tscn")

func _on_volume_slider_value_changed(value: float) -> void:
	$Control/HBoxContainer/VolumePercentage.text = str(roundf(value)).replace(".0", "%")

func _on_language_option_button_item_selected(index: int) -> void:
	match index:
		0:
			LocalizationService.set_language(Const.Languages.ENGLISH)
		1:
			LocalizationService.set_language(Const.Languages.GERMAN)
			
func _on_language_changed():
	_set_text_to_language()
