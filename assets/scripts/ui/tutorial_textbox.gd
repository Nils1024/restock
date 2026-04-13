extends CanvasLayer

@onready var textbox_container = $TextboxContainer
@onready var text = $TextboxContainer/MarginContainer/VBoxContainer/HBoxContainer/Text
@onready var continue_button = $TextboxContainer/MarginContainer/VBoxContainer/HBoxContainer2/ContinueButton

enum State {
	READY,
	READING,
	FINISHED
}

var current_state: State = State.READY
var text_queue: Array[String] = []
var tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_textbox()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				tween.stop()
				tween.kill()
				text.visible_characters = len(text.text)
				change_state(State.FINISHED)
				_on_tween_finished()

func _on_continue_button_pressed() -> void:
	match current_state:
		State.FINISHED:
			change_state(State.READY)
			hide_textbox()
	
func add_text_to_queue(text: String) -> void:
	text_queue.push_back(text)
	
func display_text():
	text.text = text_queue.pop_front()
	text.visible_characters = 0
	change_state(State.READING)
	show_textbox()
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(_on_tween_finished, CONNECT_ONE_SHOT)
	tween.tween_property(text, "visible_characters", len(text.text), 1.2)
	
func _on_tween_finished() -> void:
	continue_button.disabled = false
	change_state(State.FINISHED)
	
func hide_textbox() -> void:
	textbox_container.hide()
	
func show_textbox() -> void:
	textbox_container.show()
	continue_button.disabled = true
	
func change_state(new_state: State) -> void:
	current_state = new_state
