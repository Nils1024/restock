extends Node

class config:
	const CONFIG_FILE: String = "user://settings.cfg"
	const SETTINGS_SECTION_KEY: String = "settings"
	
	const LANGUAGE_KEY: String = "language"
	const MAX_THREADS: int = 4
	
class Languages:
	const ENGLISH: String = "en"
	const GERMAN: String = "de"
	
class World:
	const CHUNK_SIZE: int = 32
	const MIN_WORLD_COORD: int = -3000
	const MAX_WORLD_COORD: int = 3000
