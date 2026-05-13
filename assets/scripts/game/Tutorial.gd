extends Node

class_name Tutorial

signal tutorial_completed

@export var textbox: Node

var assistant_speaking: CompressedTexture2D = load("res://assets/images/tutorial/Tutor 1.svg")
var tutorial_text = [
	{"text": "Hi, it looks like you are our new manager.", "image": assistant_speaking},
	{"text": "I'm Anna, your Assistant. I will help you to get started.", "image": assistant_speaking},
	{"text": "We want to expand into new territory and we need your help to achieve that.", "image": assistant_speaking},
	{"text": "Firstly, we need a HQ to manage our operations. Open the shop and place an HQ.", "image": assistant_speaking},
	{"text": "Great job! Now that we have a HQ, we should build our first factory.", "image": assistant_speaking},
	#{"text": "See how easy it is. Now we need a consumer.", "image": assistant_speaking},
	#{"text": "Lets connect them. For this click on the street symbol in the shop and choose a fitting street.", "image": assistant_speaking},
	{"text": "Incredible! You are going to be a great manager! Continue to build more factories to increase your company's profit.", "image": assistant_speaking},
]
var current_step: int = 0

# State variables
var HQ_placed: bool = false
var factory_placed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	textbox.offset = Vector2(400, 200)
	
	textbox.text_finished.connect(_on_text_finished)
	
	await UtilityService.wait(1)
	
func start() -> void:
	textbox.visible = true
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
	
	if not current_step in [4, 5]:
		_show_next_step()
	
func _on_building_placed(item: Building) -> void:
	match item.label:
		"HQ":
			if not HQ_placed:
				HQ_placed = true
				_show_next_step()
		"Factory":
			if not factory_placed:
				factory_placed = true
				_show_next_step()
