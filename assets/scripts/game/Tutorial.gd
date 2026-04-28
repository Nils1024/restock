extends Node

class_name Tutorial

signal tutorial_completed

@export var textbox: Node

var tutorial_text = [
	{"text": "Hi, it looks like you are our new manager.", "image": null},
	{"text": "I'm Anna, your Assistant. I try to help you as much as I can.", "image": null},
	{"text": "We want to expand to new territory and we need you for this task.", "image": null},
	{"text": "Firstly, we need a HQ where we operate everything from. Click on the Shop and place it.", "image": null},
	{"text": "Great job! Now that we have a HQ we should start with our first factory!", "image": null},
	{"text": "See how easy it is. Now we need a consumer.", "image": null},
	{"text": "Lets connect them. For this click on the street symbol in the shop and choose a fitting street.", "image": null},
	{"text": "Incredible! You are going to be a great manager. Continue to build more factories and consumers so your company makes more profit.", "image": null},
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
		emit_signal("tutorial_completed")
		return
		
	textbox.add_text_to_queue(tutorial_text[current_step]["text"])
	textbox.set_image(tutorial_text[current_step]["image"])
	current_step += 1
	
func _on_text_finished() -> void:
	await UtilityService.wait(0.5)
	_show_next_step()
