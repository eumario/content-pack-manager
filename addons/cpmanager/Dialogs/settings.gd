@tool
extends PanelContainer

#region Signals
signal created_settings(settings : CPSettings)
#endregion

#region Private Variables
var _cp_version : String
#endregion

#region Public Variabes
var settings : CPSettings :
	get(): return settings
	set(value):
		settings = value
		if settings == null: return
		if get_node_or_null("%CPFolder") == null: return
		%CPFolder.get_node("FolderPath").text = settings.cp_folder
		%ExternalFolder.text = settings.external_folder
		%BuildFolder.get_node("FolderPath").text = settings.build_folder
		%PackFormat.selected = settings.format
#endregion

#region Godot Overrides
func _ready() -> void:
	%CPFolder.get_node("Browse").pressed.connect(_handle_cp_folder_browse)
	%BuildFolder.get_node("Browse").pressed.connect(_handle_build_folder_browse)
	%SaveSettings.pressed.connect(_handle_save_settings)
#endregion

#region Signal Handlers
func _handle_save_settings() -> void:
	var new_settings : CPSettings
	var new_setup : bool = false
	if FileAccess.file_exists("res://cp_settings.tres"):
		new_settings = ResourceLoader.load("res://cp_settings.tres")
	else:
		new_settings = CPSettings.new()
		new_setup = true
	
	new_settings.cp_folder = %CPFolder.get_node("FolderPath").text
	new_settings.external_folder = %ExternalFolder.text
	new_settings.build_folder = %BuildFolder.get_node("FolderPath").text
	new_settings.format = %PackFormat.selected as CPSettings.PackFormat
	new_settings.cp_version = _cp_version
	ResourceSaver.save(new_settings, "res://cp_settings.tres")
	if new_setup:
		created_settings.emit(ResourceLoader.load("res://cp_settings.tres"))

func _handle_cp_folder_browse() -> void:
	var dlg := EditorFileDialog.new()
	dlg.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	dlg.title = "Select Content Pack Folder"
	dlg.current_path = "res://"
	dlg.close_requested.connect(func(): dlg.queue_free())
	dlg.dir_selected.connect(func(path : String): %CPFolder.get_node("FolderPath").text = path)
	EditorInterface.popup_dialog_centered(dlg, Vector2i(600,400))

func _handle_build_folder_browse() -> void:
	var dlg := EditorFileDialog.new()
	dlg.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	dlg.title = "Select Build Folder"
	dlg.current_path = "res://"
	dlg.close_requested.connect(func(): dlg.queue_free())
	dlg.dir_selected.connect(func(path : String): %BuildFolder.get_node("FolderPath").text = path)
	EditorInterface.popup_dialog_centered(dlg, Vector2i(600,400))
#endregion
