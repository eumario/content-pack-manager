@tool
extends Window

const CREATE_EDIT_CP_DLG = preload("res://addons/cpmanager/Dialogs/create_edit_cp_dialog.tscn")

#region Private Variables
var _root : TreeItem
#endregion

#region Properties
var settings : CPSettings :
	set(value):
		settings = value
		if get_node_or_null("%BuildFolder") != null and settings != null:
			%CPFolder.get_node("FolderPath").text = settings.cp_folder
			%ExternalFolder.text = settings.external_folder
			%BuildFolder.get_node("FolderPath").text = settings.build_folder
	get(): return settings
#endregion

#region Godot Overrides
func _ready() -> void:
	%CPFolder.get_node("Browse").pressed.connect(_handle_cp_folder_browse)
	%BuildFolder.get_node("Browse").pressed.connect(_handle_build_folder_browse)
	%SaveSettings.pressed.connect(_handle_save_settings)
	%CreateCP.pressed.connect(_handle_create_cp)
	self.settings = settings
	%CPList.clear()
	%CPList.set_column_title(0, "Content Pack")
	%CPList.set_column_title(1, "Author")
	%CPList.set_column_title(2, "Version")
	%CPList.set_column_expand(0,true)
	%CPList.set_column_expand(1,true)
	%CPList.set_column_expand(2,false)
	_root = %CPList.create_item()
	if settings.cp_folder != "":
		_scan_cps()
#endregion

#region Private Functions
func _scan_cps() -> void:
	if !DirAccess.dir_exists_absolute(settings.cp_folder):
		return
	for folder in DirAccess.get_directories_at(settings.cp_folder):
		var cp_folder = settings.cp_folder.path_join(folder)
		if FileAccess.file_exists(cp_folder.path_join("content_pack.tres")):
			var res = load(cp_folder.path_join("content_pack.tres")) as CPConfig
			if res == null:
				continue
			var item = _root.create_child()
			item.set_cell_mode(0,TreeItem.CELL_MODE_CHECK)
			item.set_checked(0,false)
			item.set_text(0, res.name)
			item.set_text(1, res.author)
			item.set_text(2, res.version)
#endregion

#region Signal Handlers
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

func _handle_save_settings() -> void:
	var settings := CPSettings.new()
	settings.cp_folder = %CPFolder.get_node("FolderPath").text
	settings.external_folder = %ExternalFolder.text
	settings.build_folder = %BuildFolder.get_node("FolderPath").text
	ResourceSaver.save(settings, "res://cp_settings.tres")

func _handle_create_cp() -> void:
	var dlg = CREATE_EDIT_CP_DLG.instantiate();
	dlg.close_requested.connect(func(): dlg.queue_free())
	dlg.edit = false
	dlg.confirmed.connect(_handle_dialog_create_cp)
	dlg.canceled.connect(func(): dlg.queue_free())
	EditorInterface.popup_dialog_centered(dlg, Vector2i(500,400))

func _handle_dialog_create_cp() -> void:
	pass
#endregion
