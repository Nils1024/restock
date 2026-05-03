extends Node2D

enum ButtonType {
	LOAD_SAVE,
	BACK
}

const saveCard = preload("res://assets/scenes/util/ui/save_card.tscn")

@onready var seedEdit = $MarginContainer/MarginContainer/VBoxContainer2/GridContainer/SeedEdit
@onready var nameEdit = $MarginContainer/MarginContainer/VBoxContainer2/GridContainer/NameEdit
@onready var saveCardContainer = $ScrollContainer/SaveCardContainer
@onready var avatarHBox = $MarginContainer/MarginContainer/VBoxContainer2/GridContainer/VBoxContainer/AvatarHBox

var avatars: Array[Texture2D] = [
	preload("res://assets/images/avatars/Avatar 1.svg"),
	preload("res://assets/images/avatars/Avatar 2.svg"),
	preload("res://assets/images/avatars/Avatar 3.svg"),
	preload("res://assets/images/avatars/Avatar 4.svg"),
]
var _selected_avatar_index: int = 0
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
	_load_avatars()


func _load_avatars() -> void:
	for i in range(avatars.size()):
		var panel: PanelContainer = PanelContainer.new()
		
		var btn: TextureButton = TextureButton.new()
		btn.texture_normal = avatars[i]
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.custom_minimum_size = Vector2i(96, 96)
		btn.size = Vector2i(96, 96)
		btn.pressed.connect(_on_avatar_selected.bind(i))
		
		panel.add_child(btn)
		avatarHBox.add_child(panel)


func _on_avatar_selected(index: int):
	SimpleLogger.debug("Avatar at index <%d> selected" % index)
	_selected_avatar_index = index
	_update_avatar_button_styles()


func _update_avatar_button_styles():
	for i in range(avatarHBox.get_child_count()):
		var panel: PanelContainer = avatarHBox.get_child(i)
		
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.set_border_width_all(3)
		style.bg_color = Color(0, 0, 0, 0)
		
		if i == _selected_avatar_index:
			style.border_color = Color(1, 1, 0)
		else:
			style.border_color = Color(0, 0, 0, 0)
			
		panel.add_theme_stylebox_override("panel", style)


func _on_timer_timeout() -> void:
	match current_button_type:
		ButtonType.LOAD_SAVE:
			var scene: PackedScene = load("res://assets/scenes/game.tscn")
			var instance: Game = scene.instantiate()
			instance.data = data
			get_tree().root.add_child(instance)
			get_tree().current_scene.queue_free()
			get_tree().current_scene = instance
		ButtonType.BACK:
			#TODO: Back to main menu
			pass

func _on_save_card_card_pressed(save_id: int) -> void:
	current_button_type = ButtonType.LOAD_SAVE
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
	_on_avatar_selected(0)

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
	
	var all_saves = DataService.get_all()
	if all_saves.is_empty():
		save.id = 0
	else:
		save.id = all_saves.map(func(s): return s.id).max() + 1
	
	save.generation_seed = int(seedEdit.text)
	save.name = nameEdit.text
	save.selected_avatar_index = _selected_avatar_index
	DataService.create(save.id, save)
	_on_cancel_new_game_pressed()
	_update_savecards()


func _update_savecards() -> void:
	for child in saveCardContainer.get_children():
		child.queue_free()
		
	for save in DataService.get_all():
		SimpleLogger.debug("Save Found: %s" % save.to_dict())
		var card: SaveCard = saveCard.instantiate()
		card.setup(save.id, save.name)
		card.load_pressed.connect(_on_save_card_card_pressed)
		card.delete_pressed.connect(_on_save_card_delete_pressed)
		saveCardContainer.add_child(card)
