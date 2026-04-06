extends Control

signal card_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SaveButton.text = get_meta("Text", "Save")


func _on_save_button_pressed() -> void:
	emit_signal("card_pressed")
