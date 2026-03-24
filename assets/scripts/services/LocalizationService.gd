extends Node

signal language_changed

var supported = [Const.Languages.ENGLISH, Const.Languages.GERMAN]
var current_language = Const.Languages.ENGLISH

func _ready() -> void:
	load_language()
	
func load_language():
	var config = ConfigFile.new()
	config.load(Const.config.CONFIG_FILE)
	
	var lang = config.get_value(Const.config.SETTINGS_SECTION_KEY, Const.config.LANGUAGE_KEY, "")
	
	if lang == "" or not lang in supported:
		lang = OS.get_locale().substr(0, 2)
		
	if not lang in supported:
		lang = Const.Languages.ENGLISH
		
	set_language(lang)

func set_language(lang: String):
	current_language = lang
	TranslationServer.set_locale(current_language)
	
	save_language(lang)
	emit_signal("language_changed")
	
func save_language(lang: String):
	var config = ConfigFile.new()
	config.load(Const.config.CONFIG_FILE)
	config.set_value(Const.config.SETTINGS_SECTION_KEY, Const.config.LANGUAGE_KEY, lang)
	config.save(Const.config.CONFIG_FILE)
