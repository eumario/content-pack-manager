@tool
extends EditorScript

func _ignore_check(ignore : String, file : String) -> bool:
	print("DEBUG> Ignore: ", ignore)
	print("DEBGU> File: ", file)
	print("DEBUG> file.contains(ignore): ", file.contains(ignore))
	return file.contains(ignore)

func _get_all_files(files : Array[String], path : String, ext : String = "", ignore_files : Array[String] = []) -> void:
	var dirFiles = DirAccess.get_files_at(path)
	for file in dirFiles:
		if ext == "" or ext == file.get_extension():
			if ignore_files.any(_ignore_check.bind(file)):
				continue
			files.append(path.path_join(file))
	
	var dirs = DirAccess.get_directories_at(path)
	for dir in dirs:
		_get_all_files(files, path.path_join(dir), ext, ignore_files)

# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var files : Array[String] = []
	var path := "res://Games/test_one"
	var ext := ""
	var ignore_files : Array[String] = [".import"]
	_get_all_files(files, path, ext, ignore_files)
	print(JSON.stringify(files, "\t"))
