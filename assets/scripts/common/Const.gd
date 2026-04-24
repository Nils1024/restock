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
