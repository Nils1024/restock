class_name GameSaveData

var id = 0
var generation_seed: int = 0
var name: String = ""
var money: int = 1000
var building_data: Dictionary

func to_dict() -> Dictionary:
	return {
		"id": id,
		"seed": generation_seed,
		"name": name
	}

static func from_dict(dict: Dictionary) -> GameSaveData:
	var data = GameSaveData.new()
	data.id = dict.get("id", 0)
	data.generation_seed = dict.get("seed", 123456789)
	data.name = dict.get("name", "Unnamed")
	return data
