extends CanvasLayer

@onready var textbox_container = $TextboxContainer
@onready var label = $TextboxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Text
@onready var continue_button = $TextboxContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/ContinueButton

enum State {
	READY,
	READING,
	FINISHED
}

signal text_finished

var _current_state: State = State.READY
var _text_queue: Array[String] = []
var _tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_textbox()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match _current_state:
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				_tween.kill()
				label.visible_characters = len(label.text)
				change_state(State.FINISHED)
				_on_tween_finished()

func _on_continue_button_pressed() -> void:
	match _current_state:
		State.FINISHED:
			change_state(State.READY)
			hide_textbox()
			if _text_queue.is_empty():
				text_finished.emit()
			else:
				display_text()
	
func add_text_to_queue(text: String) -> void:
	_text_queue.push_back(text)
	if _current_state == State.READY:
		display_text()
	
func set_image(image: Texture2D) -> void:
	var texture_rect = $TextboxContainer/MarginContainer/HBoxContainer/TextureRect
	texture_rect.texture = image
	texture_rect.visible = image != null
	
func display_text():
	set_image(null)
	label.text = _text_queue.pop_front()
	label.visible_characters = 0
	change_state(State.READING)
	show_textbox()
	
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_LINEAR)
	_tween.finished.connect(_on_tween_finished, CONNECT_ONE_SHOT)
	_tween.tween_property(label, "visible_characters", len(label.text), 1.2)
	
func _on_tween_finished() -> void:
	continue_button.disabled = false
	change_state(State.FINISHED)
	
func hide_textbox() -> void:
	textbox_container.hide()
	
func show_textbox() -> void:
	textbox_container.show()
	continue_button.disabled = true
	
func change_state(new_state: State) -> void:
	_current_state = new_state
	
func is_ready() -> bool:
	return _current_state == State.READY and _text_queue.is_empty()
