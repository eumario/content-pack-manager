@tool
extends PanelContainer

signal build_finished(pack : CPConfig)
signal build_success(pack : CPConfig)
signal build_failed(pack : CPConfig)

enum LogLevel { INFO, DEBUG, ERROR }

const LogColors : Array[Color] = [
	Color.WHITE,
	Color.YELLOW,
	Color.GREEN,
]

var settings : CPSettings

var _stdout_thread : Thread
var _stderr_thread : Thread


func _ignore_check(ignore : String, file : String) -> bool:
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

func start_build(pack : CPConfig, path : String) -> void:
	var start = Time.get_unix_time_from_system()
	var success = true
	
	_log_message(LogLevel.INFO, "Beginning Build of %s..." % pack.name)
	
	var cfg = ExportConfigurator.new()
	cfg.load_config()
	
	_log_message(LogLevel.INFO, "Updating Pack Information...")
	
	var files : Array[String] = []
	_get_all_files(files, path, "", [".import", ".uid"])
	if cfg.has_pack_preset(pack):
		cfg.update_pack_preset(pack, files)
	else:
		cfg.add_pack_preset(pack, files)
	
	_log_message(LogLevel.INFO, "Pack information updated.")
	
	_log_message(LogLevel.INFO, "Exporting pack contents...")
	
	var project_folder = ProjectSettings.globalize_path("res://")
	var pack_config = "pack_%s" % pack.name.to_snake_case()
	var pack_file = ProjectSettings.globalize_path(settings.build_folder.path_join(path.rsplit("/")[-1]))
	pack_file += ".pck" if settings.format == CPSettings.PackFormat.PCK else ".zip"
	
	var arguments := PackedStringArray(["--headless", "--path", project_folder, "--export-pack", pack_config, pack_file])
	
	_log_message(LogLevel.DEBUG, "Executing: %s %s" % [OS.get_executable_path(), arguments])
	var proc : Dictionary = OS.execute_with_pipe(OS.get_executable_path(), arguments)
	if proc.is_empty():
		_log_message(LogLevel.ERROR, "Failed to execute build for pack.")
		_log_message(LogLevel.DEBUG, "Command Line: %s %s" % [OS.get_executable_path(), arguments])
		success = false
	else:
		_stdout_thread = Thread.new()
		_stdout_thread.start(_thread_stdout.bind(proc.stdio))
		_stderr_thread = Thread.new()
		_stderr_thread.start(_thread_stderr.bind(proc.stderr))
		while _stdout_thread.is_alive() and _stderr_thread.is_alive():
			await get_tree().process_frame
			if not OS.is_process_running(proc.pid):
				break
		
		if _stderr_thread.is_alive():
			_stderr_thread.wait_to_finish()
		if _stdout_thread.is_alive():
			_stdout_thread.wait_to_finish()
		
		proc.stdio.close()
		
		if not FileAccess.file_exists(arguments[5]):
			_log_message(LogLevel.ERROR, "Build failed, review output from above.")
			success = false
		else:
			_log_message(LogLevel.INFO, "Build completed successfully.")
	
	var total = Time.get_unix_time_from_system() - start
	_log_message(LogLevel.INFO, "Finished in %s" % Time.get_time_string_from_unix_time(total))
	if success:
		build_success.emit(pack)
	else:
		build_failed.emit(pack)
	build_finished.emit(pack)

func _thread_stdout(pipe : FileAccess):
	while pipe.is_open() and pipe.get_error() == OK:
		_log_console.call_deferred(char(pipe.get_8()))

func _thread_stderr(pipe : FileAccess):
	while pipe.is_open() and pipe.get_error() == OK:
		_log_console_error.call_deferred(char(pipe.get_8()))

func _log_message(level : LogLevel, message : String) -> void:
	%History.push_color(LogColors[level])
	%History.push_bold()
	var stamp = Time.get_datetime_dict_from_system()
	match level:
		LogLevel.INFO: %History.add_text("INFO - ")
		LogLevel.DEBUG: %History.add_text("DEBUG - ")
		LogLevel.ERROR: %History.add_text("ERROR - ")
	%History.add_text("[%02d:%02d:%02d]" % [stamp.hour, stamp.minute, stamp.second])
	%History.pop_all()
	%History.add_text(": %s" % message)
	%History.newline()

func _log_console(char) -> void:
	if char == "\n":
		%History.newline()
		return
	%History.push_color(Color.GREEN)
	%History.add_text(char)
	%History.pop_all()

func _log_console_error(char) -> void:
	if char == "\n":
		%History.newline()
		return
	%History.push_color(Color.RED)
	%History.add_text(char)
	%History.pop_all()
