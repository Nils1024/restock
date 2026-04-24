class_name GameSaveData

var uuid = 123
var generation_seed: int = 0
var name: String = ""
var money: int = 1000
var building_data: Dictionary

func to_dict() -> Dictionary:
	return {
		"seed": generation_seed
	}

static func from_dict(dict: Dictionary) -> GameSaveData:
	var data = GameSaveData.new()
	data.generation_seed = dict.get("seed", 123456789)
	return data
