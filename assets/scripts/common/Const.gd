extends Node

class config:
	const CONFIG_FILE = "user://settings.cfg"
	const SETTINGS_SECTION_KEY = "settings"
	
	const LANGUAGE_KEY = "language"
	const MAX_THREADS = 4
	
class Languages:
	const ENGLISH = "en"
	const GERMAN = "de"
	
class World:
	const CHUNK_SIZE = 32
	const MIN_WORLD_COORD: int = -3000
	const MAX_WORLD_COORD: int = 3000
