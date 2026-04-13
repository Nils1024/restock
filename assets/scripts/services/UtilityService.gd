extends Node

func wait(seconds: float):
	return get_tree().create_timer(seconds).timeout
