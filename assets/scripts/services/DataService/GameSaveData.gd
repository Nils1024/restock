class_name GameSaveData

var id = 0
var generation_seed: int = 0
var name: String = ""
var selected_avatar_index: int = 0
var money: int = 1000
var tutorial_played: bool = false
var building_data: Dictionary

func to_dict() -> Dictionary:
	return {
		"id": id,
		"seed": generation_seed,
		"name": name,
		"avatar": selected_avatar_index,
		"money": money,
		"tutorial_played": tutorial_played
	}

static func from_dict(dict: Dictionary) -> GameSaveData:
	var data = GameSaveData.new()
	data.id = dict.get("id", 0)
	data.generation_seed = dict.get("seed", 123456789)
	data.name = dict.get("name", "Unnamed")
	data.selected_avatar_index = dict.get("avatar", 0)
	data.money = dict.get("money", 1000)
	data.tutorial_played = dict.get("tutorial_played", false)
	return data
