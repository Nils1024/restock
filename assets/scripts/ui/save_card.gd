extends PanelContainer

class_name SaveCard

signal load_pressed
signal delete_pressed

var _save_id: int

func setup(save_id: int, text: String):
	_save_id = save_id
	$MarginContainer/VBoxContainer/Control/Label.text = text


func _on_save_button_pressed() -> void:
	emit_signal("load_pressed", _save_id)


func _on_delete_button_pressed() -> void:
	emit_signal("delete_pressed", _save_id)
