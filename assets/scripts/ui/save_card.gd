extends PanelContainer

class_name SaveCard

signal card_pressed
signal delete_pressed

var _save_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/VBoxContainer/Control/Label.text = get_meta("Text", "Save")


func setup(save_id: int):
	_save_id = save_id


func _on_save_button_pressed() -> void:
	emit_signal("card_pressed", _save_id)


func _on_delete_button_pressed() -> void:
	emit_signal("delete_pressed", _save_id)
