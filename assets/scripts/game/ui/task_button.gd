extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_task_button_pressed() -> void:
	$TaskWindow.show()


func _on_texture_button_pressed() -> void:
	$TaskWindow.hide()
