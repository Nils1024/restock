extends Node2D

enum ButtonType {
	SAVE_1,
	SAVE_2,
	SAVE_3,
}

var current_button_type = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FadeTransition.show()
	$FadeTransition/AnimationPlayer.play("Fade_out")

func _on_save_1_pressed() -> void:
	current_button_type = ButtonType.SAVE_1
	$FadeTransition.show()
	$FadeTransition/Timer.start()
	$FadeTransition/AnimationPlayer.play("Fade_in")

func _on_timer_timeout() -> void:
	match current_button_type:
		ButtonType.SAVE_1:
			get_tree().change_scene_to_file("res://assets/scenes/game.tscn")
