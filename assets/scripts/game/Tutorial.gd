extends Node

class_name Tutorial

signal on_tutorial_complete

@export var textbox: Node

var tutorial_text = [
	{"text": "Welcome to Restock", "image": null},
	{"text": "You joined the ... company who wants to expand to new territory.", "image": null},
]
var current_step: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	textbox.offset = Vector2(400, 200)
	
	textbox.text_finished.connect(_on_text_finished)
	
	await UtilityService.wait(1)
	
func start() -> void:
	_show_next_step()
	
func _show_next_step() -> void:
	if current_step >= tutorial_text.size():
		emit_signal("on_tutorial_complete")
		return
		
	textbox.add_text_to_queue(tutorial_text[current_step]["text"])
	textbox.set_image(tutorial_text[current_step]["image"])
	current_step += 1
	
func _on_text_finished() -> void:
	await UtilityService.wait(0.5)
	_show_next_step()
