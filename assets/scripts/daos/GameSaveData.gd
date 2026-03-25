class_name GameSaveData

var seed: int = 123

func to_dict() -> Dictionary:
	return {
		"seed": seed
	}

static func from_dict(dict: Dictionary) -> GameSaveData:
	var data = GameSaveData.new()
	data.seed = dict.get("seed", 123)
	return data
