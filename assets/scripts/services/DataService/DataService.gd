extends Node

var _config = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_config.load(Const.config.CONFIG_FILE)

func create(data: GameSaveData) -> Error:
	if _config.has_section(Const.Config.SETTINGS_SECTION_KEY):
		push_warning("GameSaveRepository.create: save already exists – use update()")
		return ERR_ALREADY_EXISTS
		
	return _write(data)
	
	
func load_save(save_id: int) -> GameSaveData:
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
	
	
func update(save_id: int, new_data: GameSaveData) -> void:
	pass
	
	
func delete(save_id: int) -> void:
	pass
	
func _write(data: GameSaveData) -> Error:
	var dict: Dictionary = data.to_dict()
	for key in dict.keys():
		_config.set_value(Const.Config.SETTINGS_SECTION_KEY, key, dict[key])
	return _config.save(Const.Config.CONFIG_FILE)
