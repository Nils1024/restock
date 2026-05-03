extends Node

var _saveFile = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_saveFile.load(Const.Save.SAVE_FILE)
	
	
func _get_section(save_id: int) -> String:
	return "%s%d" % [Const.Save.SECTION_PREFIX, save_id]


func create(save_id: int, data: GameSaveData) -> Error:
	var section: String = _get_section(save_id)
	
	if _saveFile.has_section(section):
		push_warning("GameSaveRepository.create: save already exists – use update()")
		return ERR_ALREADY_EXISTS
		
	return _write(save_id, data)
	
	
func load_save(save_id: int) -> GameSaveData:
	var section: String = _get_section(save_id)
	
	if not _saveFile.has_section(section):
		return GameSaveData.new()
	
	var dict: Dictionary = {}
	var keys = _saveFile.get_section_keys(section)
	
	for key in keys:
		dict[key] = _saveFile.get_value(section, key)
	
	return GameSaveData.from_dict(dict)
	
	
func update(save_id: int, new_data: GameSaveData) -> Error:
	var section: String = _get_section(save_id)
	
	if not _saveFile.has_section(section):
		push_warning("GameSaveRepository.update: save does not exists – use create()")
		return ERR_DOES_NOT_EXIST
		
	return _write(save_id, new_data)
	
	
func delete(save_id: int) -> Error:
	var section: String = _get_section(save_id)
	
	if not _saveFile.has_section(section):
		push_warning("GameSaveRepository.delete: cannot delete non exisiting save")
		return ERR_DOES_NOT_EXIST
		
	_saveFile.erase_section(section)
	return _saveFile.save(Const.Save.SAVE_FILE)
	
	
func get_all() -> Array[GameSaveData]:
	var all_saves: Array[GameSaveData] = []
	
	for section in _saveFile.get_sections():
		var save_id: int = section.split("_").get(1).to_int()
		all_saves.append(load_save(save_id))
		
	return all_saves
	
	
func _write(save_id: int, data: GameSaveData) -> Error:
	var section: String = _get_section(save_id)
	var dict: Dictionary = data.to_dict()
	
	for key in dict.keys():
		_saveFile.set_value(section, key, dict[key])
		
	return _saveFile.save(Const.Save.SAVE_FILE)
