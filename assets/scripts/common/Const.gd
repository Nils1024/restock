extends Node

class Config:
	const CONFIG_FILE: String = "user://settings.cfg"
	const SETTINGS_SECTION_KEY: String = "settings"
	
	const LANGUAGE_KEY: String = "language"
	const MAX_THREADS: int = 4


class Save:
	const SAVE_FILE: String = "user://savegames.cfg"
	const SECTION_PREFIX = "SaveSlot_"
	const AUTO_SAVE_PERIOD_IN_SEC = 180


class Languages:
	const ENGLISH: String = "en"
	const GERMAN: String = "de"
	
	const LANGUAGE_DISPLAY_NAMES = {
		ENGLISH: "English",
		GERMAN: "Deutsch"
	}


class World:
	const CHUNK_SIZE: int = 32
	const MIN_WORLD_COORD: int = -1500
	const MAX_WORLD_COORD: int = 1500


class Camera:
	const DRAG_THRESHOLD: int = 10


class Generation:
	const ADJECTIVES = [
			"Industrial", "Automated", "Modular", "Efficient", "Advanced", "Intigrated",
			"Dynamic", "Scalable", "Optimized", "Distributed"
		]
		
	const NOUNS = [
		"Factory", "Network", "Hub", "System", "Chain", "Complex", "Grid", "Plant", "Facility"
	]

	const SUFFIXES = ["", " Prime", " X"]


class Shop:
	const ShopCard = preload("res://assets/scenes/util/ui/ShopItemCard.tscn")
	const SHOP_ITEMS_PATHS = [
		"res://assets/data/shop_items/HQ.tres",
		"res://assets/data/shop_items/Factory.tres",
		"res://assets/data/shop_items/Street.tres"
	]


class Building:
	const BUILDING_DICT: Dictionary = {
		"HQ": {
			"drag": false,
			"income": 0,
			"tiles": [
				{"offset": Vector2i(0, 0), "atlas": Vector2i(0, 0)},
				{"offset": Vector2i(1, 0), "atlas": Vector2i(1, 0)},
				{"offset": Vector2i(2, 0), "atlas": Vector2i(2, 0)},
				{"offset": Vector2i(0, 1), "atlas": Vector2i(0, 1)},
				{"offset": Vector2i(1, 1), "atlas": Vector2i(1, 1)},
			]
		},
		"Factory": {
			"drag": false,
			"income": 5,
			"tiles": [
				{"offset": Vector2i(0, 0), "atlas": Vector2i(0, 2)},
				{"offset": Vector2i(1, 0), "atlas": Vector2i(1, 2)},
			]
		},
		"Street": {
			"drag": true,
			"income": 0,
			"tiles": [
				{"offset": Vector2i(0, 0), "atlas": Vector2i(0, 3)},
			]
		},
	}
