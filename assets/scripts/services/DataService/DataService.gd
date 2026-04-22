extends Node

var config = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	config.load(Const.config.CONFIG_FILE)

func new(data: GameSaveData) -> void:
	var dict = data.to_dict()
	
	for key in dict.keys():
		config.set_value(
			Const.config.SETTINGS_SECTION_KEY,
			key,
			dict[key]
		)
	
	config.save(Const.config.CONFIG_FILE)
	
func update(save_id: int, new_data: GameSaveData) -> void:
	pass
	
func load(save_id: int) -> GameSaveData:
	var config = ConfigFile.new()
	
	if config.load(Const.config.CONFIG_FILE) != OK:
		return GameSaveData.new()
	
	var dict: Dictionary = {}
	
	var keys = config.get_section_keys(Const.config.SETTINGS_SECTION_KEY)
	if keys == null:
		return GameSaveData.new()
	
	for key in keys:
		dict[key] = config.get_value(
			Const.config.SETTINGS_SECTION_KEY,
			key
		)
	
	return GameSaveData.from_dict(dict)
	
func delete(save_id: int) -> void:
	pass
