extends Node

signal language_changed

var supported = ["en", "de"]
var current_language = "en"

func _ready() -> void:
	load_language()
	
func load_language():
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	
	var lang = config.get_value("settings", "language", "")
	
	if lang == "" or not lang in supported:
		lang = OS.get_locale().substr(0, 2)
		
	if not lang in supported:
		lang = "en"
		
	set_language(lang)

func set_language(lang: String):
	current_language = lang
	TranslationServer.set_locale(current_language)
	
	save_language(lang)
	emit_signal("language_changed")
	
func save_language(lang: String):
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("settings", "language", lang)
	config.save("user://settings.cfg")
