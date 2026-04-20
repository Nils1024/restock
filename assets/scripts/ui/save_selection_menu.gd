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
	
	# TODO: Fetch save data and generate save cards


func _on_timer_timeout() -> void:
	match current_button_type:
		ButtonType.SAVE_1:
			get_tree().change_scene_to_file("res://assets/scenes/game.tscn")


func _on_save_card_card_pressed() -> void:
	current_button_type = ButtonType.SAVE_1
	start_fade_in_transition()


func _on_save_card_2_card_pressed() -> void:
	current_button_type = ButtonType.SAVE_2
	start_fade_in_transition()


func _on_save_card_3_card_pressed() -> void:
	current_button_type = ButtonType.SAVE_3
	start_fade_in_transition()
	
func start_fade_in_transition():
	$FadeTransition.show()
	$FadeTransition/Timer.start()
	$FadeTransition/AnimationPlayer.play("Fade_in")

func _on_new_game_pressed() -> void:
	$MarginContainer.visible = true
	

func _on_cancel_new_game_pressed() -> void:
	$MarginContainer.visible = false
