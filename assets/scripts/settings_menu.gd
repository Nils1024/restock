extends Node2D

enum ButtonType {
	BACK
}

var current_button_type = null

func _ready() -> void:
	$FadeTransition.show()
	$FadeTransition/AnimationPlayer.play("Fade_out")

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
