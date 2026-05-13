@tool
extends EditorScript

func _run() -> void:
	const file = Const.Save.SAVE_FILE
	
	if FileAccess.file_exists(file):
		var err = DirAccess.remove_absolute(file)
		
		if err == OK:
			print("Saves deleted")
		else:
			print("Error while deleting save games: ", err)
	else:
		print("File not found:", file)
