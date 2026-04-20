class_name GameSaveData

var generation_seed: int = 123

func to_dict() -> Dictionary:
	return {
		"seed": generation_seed
	}

static func from_dict(dict: Dictionary) -> GameSaveData:
	var data = GameSaveData.new()
	data.seed = dict.get("seed", 123)
	return data
