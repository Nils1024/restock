extends MarginContainer

const content: Array[Dictionary] = [
	{"text": "Page 1", "image": null},
	{"text": "Page 2", "image": null},
	{"text": "Page 3", "image": null}
]

@onready var textbox = $MarginContainer/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/Text
@onready var circle_container: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer
@onready var selected_style: StyleBoxFlat = $MarginContainer/VBoxContainer/HBoxContainer/Panel.get_theme_stylebox("panel")
@onready var unselected_style: StyleBoxFlat = $MarginContainer/VBoxContainer/HBoxContainer/Panel2.get_theme_stylebox("panel")

var selected_page: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_content()


func _on_close_btn_pressed() -> void:
	hide()


func _on_arrow_left_pressed() -> void:
	selected_page = wrapi(selected_page - 1, 0, 3)
	_update_content()


func _on_arrow_right_pressed() -> void:
	selected_page = wrapi(selected_page + 1, 0, 3)
	_update_content()


func _update_content() -> void:
	textbox.text = content[selected_page]["text"]
	
	for i in range(circle_container.get_child_count()):
		var panel: Panel = circle_container.get_child(i)
		
		if i == selected_page:
			panel.add_theme_stylebox_override("panel", selected_style)
		else:
			panel.add_theme_stylebox_override("panel", unselected_style)
