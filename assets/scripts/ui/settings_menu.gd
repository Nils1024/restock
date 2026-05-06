extends MarginContainer

@onready var language_option_button: OptionButton = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/LanguageOptionButton
@onready var resolution_option_button: OptionButton = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/ResolutionOptionButton
@onready var volume_slider: HSlider = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/VolumeHBox/VolumeSlider
@onready var volume_label: Label = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/VolumeHBox/VolumePercentage

var supported_resolutions: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

func _ready() -> void:
	LocalizationService.language_changed.connect(_on_language_changed)
	_populate_language_button()
	_populate_resolution_button()
	
	_on_language_changed()
	
	AudioService.set_volume(0.5)
	var current_volume = AudioService.get_volume()
	volume_slider.set_value_no_signal(current_volume * 100)
	volume_label.text = str(roundf(current_volume * 100)).replace(".0", "%")


func _populate_resolution_button() -> void:
	resolution_option_button.clear()
	
	if OS.has_feature("web"):
		resolution_option_button.add_item("Deactivated in web")
		resolution_option_button.disabled = true
		return
	
	for resolution in supported_resolutions:
		var text = "%d x %d" % [resolution.x, resolution.y]
		resolution_option_button.add_item(text)


func _populate_language_button() -> void:
	language_option_button.clear()
	
	for lang in LocalizationService.supported:
		var display_name: String = Const.Languages.LANGUAGE_DISPLAY_NAMES.get(lang, lang)
		language_option_button.add_item(display_name)


func _on_language_changed() -> void:
	_sync_language_button()
	_set_text_to_language()


func _sync_language_button() -> void:
	var lang_index = LocalizationService.supported.find(LocalizationService.current_language)
	
	if lang_index != -1:
		language_option_button.selected = lang_index


func _set_text_to_language() -> void:
	# TODO 
	#$Control/Back.text = "Back"
	pass


func _on_close_button_pressed() -> void:
	hide()


func _on_volume_slider_value_changed(value: float) -> void:
	AudioService.set_volume(value / 100)
	volume_label.text = str(roundf(value)).replace(".0", "%")


func _on_language_option_button_item_selected(index: int) -> void:
	var selected_language = LocalizationService.supported[index]
	LocalizationService.set_language(selected_language)


func _on_resolution_option_button_item_selected(index: int) -> void:
		DisplayServer.window_set_size(Vector2i(1920, 1080))
