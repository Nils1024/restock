extends Node2D

enum ButtonType {
	SAVE_1,
	SAVE_2,
	SAVE_3,
}

const saveCard = preload("res://assets/scenes/util/ui/save_card.tscn")

@onready var seedEdit = $MarginContainer/MarginContainer/VBoxContainer2/GridContainer/SeedEdit
@onready var nameEdit = $MarginContainer/MarginContainer/VBoxContainer2/GridContainer/NameEdit
@onready var saveCardContainer = $ScrollContainer/SaveCardContainer

var current_button_type = null
var data: GameSaveData = null

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
	
	_update_savecards()


func _on_load_button_pressed() -> void:
	pass


func _on_timer_timeout() -> void:
	match current_button_type:
		ButtonType.SAVE_1:
			var scene: PackedScene = load("res://assets/scenes/game.tscn")
			var instance: Game = scene.instantiate()
			instance.data = data
			get_tree().root.add_child(instance)
			get_tree().current_scene.queue_free()
			get_tree().current_scene = instance

func _on_save_card_card_pressed(save_id: int) -> void:
	current_button_type = ButtonType.SAVE_1
	data = DataService.load_save(save_id)
	start_fade_in_transition()


func _on_save_card_delete_pressed(save_id: int) -> void:
	if DataService.delete(save_id) == OK:
		_update_savecards()
	else:
		# TODO: Show error
		pass


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
	var save = GameSaveData.new()
	save.id = 0
	save.generation_seed = int(seedEdit.text)
	save.name = nameEdit.text
	DataService.create(save.id, save)
	_on_cancel_new_game_pressed()
	_update_savecards()


func _update_savecards() -> void:
	for child in saveCardContainer.get_children():
		child.queue_free()
		
	for save in DataService.get_all():
		print(save.to_dict())
		var card: SaveCard = saveCard.instantiate()
		card.setup(save.id, save.name)
		card.load_pressed.connect(_on_save_card_card_pressed)
		card.delete_pressed.connect(_on_save_card_delete_pressed)
		saveCardContainer.add_child(card)
