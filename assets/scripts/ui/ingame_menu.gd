extends CanvasLayer

func _on_close_pressed() -> void:
	visible = not visible


func _on_save_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/menus/main_menu.tscn")


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_help_pressed() -> void:
	$HowToPlay.show()
