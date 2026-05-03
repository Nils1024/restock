extends Node

enum Level {
	TRACE,
	DEBUG,
	INFO,
	WARN,
	ERROR,
	FATAL
}

var current_level: Level = Level.WARN

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.is_debug_build():
		current_level = Level.TRACE


func trace(msg: String) -> void:
	_log(Level.TRACE, msg)


func debug(msg: String) -> void:
	_log(Level.DEBUG, msg)


func info(msg: String) -> void:
	_log(Level.INFO, msg)


func warn(msg: String) -> void:
	_log(Level.WARN, msg)


func error(msg: String) -> void:
	_log(Level.ERROR, msg)


func fatal(msg: String) -> void:
	_log(Level.FATAL, msg)


func _log(level: Level, msg: String) -> void:
	if level < current_level:
		return
		
	var prefix: String = ""
	match level:
		Level.TRACE: prefix = "[TRACE]"
		Level.DEBUG: prefix = "[DEBUG]"
		Level.INFO: prefix = "[INFO]"
		Level.WARN: prefix = "[WARN]"
		Level.ERROR: prefix = "[ERROR]"
		Level.FATAL: prefix = "[FATAL]"
		
	var time = Time.get_time_string_from_system()
	var log_string = "%s %s %s" % [time, prefix, msg]
	
	match level:
		Level.WARN: push_warning(log_string)
		Level.ERROR, Level.FATAL: push_error(log_string)
		_: print(log_string)
