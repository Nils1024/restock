extends Node2D

enum ButtonType {
	SAVE_1,
	SAVE_2,
	SAVE_3,
}

@onready var seedEdit = $MarginContainer/MarginContainer/VBoxContainer2/GridContainer/SeedEdit
@onready var nameEdit = $MarginContainer/MarginContainer/VBoxContainer2/GridContainer/NameEdit

var current_button_type = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FadeTransition.show()
	$FadeTransition/AnimationPlayer.play("Fade_out")
	
	# Only accept digits in the seed line edit
	var regex = RegEx.new()
	regex.compile("[^0-9]")
	
	seedEdit.text_changed.connect(func(new_text: String) -> void:
		var filtered := regex.sub(new_text, "", true)
		if filtered != new_text:
			var caretPos = seedEdit.caret_column - 1
			seedEdit.text = filtered
			seedEdit.caret_column = caretPos
	)
	
	# TODO: Fetch save data and generate save cards

func _on_load_button_pressed() -> void:
	pass

func _on_timer_timeout() -> void:
	match current_button_type:
		ButtonType.SAVE_1:
			get_tree().change_scene_to_file("res://assets/scenes/game.tscn")


func _on_save_card_card_pressed() -> void:
	current_button_type = ButtonType.SAVE_1
	start_fade_in_transition()

	
func start_fade_in_transition():
	$FadeTransition.show()
	$FadeTransition/Timer.start()
	$FadeTransition/AnimationPlayer.play("Fade_in")

func _on_new_game_pressed() -> void:
	$MarginContainer.visible = true
	
	_randomize_seed()
	_randomize_name()
	
func _randomize_seed():
	seedEdit.text = str(randi())
	
func _randomize_name():
	var adj = Const.Generation.ADJECTIVES.pick_random()
	var noun = Const.Generation.NOUNS.pick_random()
	var suffix = Const.Generation.SUFFIXES.pick_random()
	
	if randi() % 2 == 0:
		var number = str(randi_range(1, 99)).pad_zeros(2)
		nameEdit.text = "%s %s %s" % [adj, noun, number]
	else:
		nameEdit.text = "%s %s%s" % [adj, noun, suffix]
	

func _on_cancel_new_game_pressed() -> void:
	$MarginContainer.visible = false


func _on_create_new_game_pressed() -> void:
	var generation_seed: int = int(seedEdit.text)
	pass
