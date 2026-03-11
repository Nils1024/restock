extends Control

enum ButtonType {
	START,
	QUIT
}

var current_button_type = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_start_game_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_game_pressed() -> void:
	get_tree().quit()
