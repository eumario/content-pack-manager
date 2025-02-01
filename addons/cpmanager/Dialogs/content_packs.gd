@tool
extends PanelContainer

#region Preload Scenes
const CREATE_EDIT_CP_DLG = preload("res://addons/cpmanager/Dialogs/create_edit_cp_dialog.tscn")
#endregion

#region Template PackScript
const _PACK_TEMPLATE_SCRIPT = """extends PackScript

# Is executed when creating the pack script for the first time.
func _setup() -> void:
	pass

# Is executed when using PackManager.configure_pack(pack, data)
func _configure(data : Variant) -> void:
	pass

# Is executed when using PackManager.enable_pack(pack)
func _enable_pack() -> void:
	pass

# Is Executed when using PackManager.disable_pack(pack)
func _disable_pack() -> void:
	pass

# Is Executed when using PackManager.is_enabled(pack)
func _is_enabled() -> bool:
	return false
"""
#endregion

#region Private Variables
var _cp_version : String
var _root : TreeItem
var _checked_cps : Array[CPConfig]
var _checked_cps_paths : Array[String]
#endregion

#region Public Variables
var settings : CPSettings :
	get(): return settings
	set(value):
		settings = value
		if settings != null and settings.cp_folder != "":
			_scan_cps()
#endregion

#region Godot Overrides
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%CreateCP.pressed.connect(_handle_create_cp)
	%EditCP.pressed.connect(_handle_edit_cp)
	%RemoveCP.pressed.connect(_handle_remove_cp)
	%BuildCB.pressed.connect(_handle_build_cp)
	
	%CPList.set_column_title(0, "")
	%CPList.set_column_title(1, "Content Pack")
	%CPList.set_column_title(2, "Author")
	%CPList.set_column_title(3, "Version")
	%CPList.set_column_expand(0, false)
	%CPList.set_column_expand(1, true)
	%CPList.set_column_expand(2, true)
	%CPList.set_column_expand(3, false)
	%CPList.item_selected.connect(_handle_cp_item_selected)
	%CPList.item_edited.connect(_handle_cp_item_checked)
	%CPList.nothing_selected.connect(_handle_cp_item_selected)
	%CPList.empty_clicked.connect(func(_x,_y): %CPList.deselect_all())
#endregion

#region Private Functions
func _scan_cps() -> void:
	%CPList.clear()
	_root = %CPList.create_item()
	if !DirAccess.dir_exists_absolute(settings.cp_folder):
		return
	for folder in DirAccess.get_directories_at(settings.cp_folder):
		var cp_folder = settings.cp_folder.path_join(folder)
		if FileAccess.file_exists(cp_folder.path_join("pack_config.tres")):
			var res = load(cp_folder.path_join("pack_config.tres")) as CPConfig
			if res == null:
				continue
			var item = _root.create_child()
			item.set_cell_mode(0,TreeItem.CELL_MODE_CHECK)
			item.set_editable(0, true)
			item.set_checked(0,false)
			item.set_text(1, res.name)
			item.set_text(2, res.author)
			item.set_text(3, res.version)
			item.set_metadata(0, res)
			item.set_metadata(1, cp_folder)

func _remove_recursive(path : String) -> void:
	var dirs = DirAccess.get_directories_at(path)
	var files = DirAccess.get_files_at(path)
	for file in files:
		DirAccess.remove_absolute(path.path_join(file))
	
	for dir in dirs:
		_remove_recursive(path.path_join(dir))
	
	DirAccess.remove_absolute(path)

func _get_all_files(path : String) -> Array[String]:
	var files = PackedStringArray(Array(DirAccess.get_files_at(path)).map(func(x): return path.path_join(x)))
	for dir in DirAccess.get_directories_at(path):
		files.append_array(_get_all_files(path.path_join(dir)))
	var final_files : Array[String] = []
	final_files.assign(files)
	return final_files
#endregion


#region Signal Handlers
func _handle_cp_item_selected() -> void:
	var item : TreeItem = %CPList.get_selected()
	var enabled = item != null
	%EditCP.disabled = !enabled
	%RemoveCP.disabled = !enabled

func _handle_cp_item_checked() -> void:
	var item : TreeItem = %CPList.get_selected()
	if item.is_checked(0):
		_checked_cps.append(item.get_metadata(0) as CPConfig)
		_checked_cps_paths.append(item.get_metadata(1) as String)
	else:
		_checked_cps.erase(item.get_metadata(0) as CPConfig)
		_checked_cps_paths.erase(item.get_metadata(0) as String)
	%BuildCB.disabled = _checked_cps.size() == 0

func _handle_create_cp() -> void:
	var dlg = CREATE_EDIT_CP_DLG.instantiate();
	dlg.edit = false
	dlg.confirmed.connect(_handle_dialog_create_cp.bind(dlg))
	dlg.canceled.connect(func(): dlg.queue_free())
	EditorInterface.popup_dialog_centered(dlg, Vector2i(500,400))

func _handle_dialog_create_cp(dlg) -> void:
	var config = CPConfig.new()
	var folder = dlg.folder_name
	var mkfolders = dlg.suggested_struct
	config.name = dlg.cp_name
	config.author = dlg.author_name
	config.version = dlg.version_string
	config.url = dlg.url_string
	config.description = dlg.description
	config.icon_path = "%s/%s/%s" % [settings.cp_folder, folder, dlg.icon_path]
	config.pack_version = _cp_version
	
	dlg.queue_free()
	
	var path = settings.cp_folder.path_join(folder)
	DirAccess.make_dir_recursive_absolute(path)
	if mkfolders:
		DirAccess.make_dir_recursive_absolute(path.path_join("Assets"))
		DirAccess.make_dir_recursive_absolute(path.path_join("Scenes"))
		DirAccess.make_dir_recursive_absolute(path.path_join("Scripts"))
	ResourceSaver.save(config, path.path_join("pack_config.tres"))
	var file = FileAccess.open(path.path_join("pack_script.gd"), FileAccess.WRITE)
	file.store_string(_PACK_TEMPLATE_SCRIPT)
	file.flush()
	file.close()
	_scan_cps()
	EditorInterface.get_resource_filesystem().scan()
	EditorInterface.get_file_system_dock().navigate_to_path(path)

func _handle_edit_cp() -> void:
	var item : TreeItem = %CPList.get_selected()
	var config : CPConfig = item.get_metadata(0) as CPConfig
	var dlg = CREATE_EDIT_CP_DLG.instantiate();
	config.setup_local_to_scene()
	dlg.edit = true
	dlg.pack_config = config
	dlg.pack_path = item.get_metadata(1) as String
	dlg.cp_name = config.name
	dlg.author_name = config.author
	dlg.version_string = config.version
	dlg.url_string = config.url
	dlg.description = config.description
	dlg.icon_path = config.icon_path
	dlg.confirmed.connect(_handle_dialog_edit_cp.bind(dlg))
	dlg.canceled.connect(func(): dlg.queue_free())
	EditorInterface.popup_dialog_centered(dlg, Vector2i(500,400))

func _handle_dialog_edit_cp(dlg) -> void:
	var config : CPConfig = dlg.pack_config
	var pack_path : String = dlg.pack_path
	config.setup_local_to_scene()
	config.name = dlg.cp_name
	config.author = dlg.author_name
	config.version = dlg.version_string
	config.url = dlg.url_string
	config.description = dlg.description
	config.icon_path = dlg.icon_path
	ResourceSaver.save(config, pack_path.path_join("pack_config.tres"))
	_scan_cps()

func _handle_remove_cp() -> void:
	var item : TreeItem = %CPList.get_selected()
	var config : CPConfig = item.get_metadata(0) as CPConfig
	var path : String = item.get_metadata(1) as String
	
	var dlg = ConfirmationDialog.new();
	dlg.title = "Confirm Delete Content Pack"
	dlg.dialog_text = "Are you sure you wish to delete '%s' from your project?" % [config.name]
	dlg.cancel_button_text = "No"
	dlg.ok_button_text = "Yes"
	dlg.canceled.connect(func(): dlg.queue_free())
	dlg.close_requested.connect(func(): dlg.queue_free())
	dlg.confirmed.connect(_handle_cp_delete.bind(config, path))
	EditorInterface.popup_dialog_centered(dlg, Vector2i(300,100))

func _handle_cp_delete(config : CPConfig, path : String) -> void:
	_remove_recursive(path)
	EditorInterface.get_resource_filesystem().scan()
	_scan_cps()

func _handle_build_cp() -> void:
	var builder := %"Build Output"
	builder.visible = true
	for config in _checked_cps:
		builder.start_build(config, _checked_cps_paths[_checked_cps.find(config)])
		await builder.build_finished
#endregion
