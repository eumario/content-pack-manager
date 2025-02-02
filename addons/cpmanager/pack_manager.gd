extends Node

## Manages all Content Packages, locating them, and managing them.

## Holds a copy of Settings configured for the Project for Content Packs.
static var settings : CPSettings

#region Private Static Variables
static var _packs : Array[CachePack] = []
static var _found : Array[String] = []
#endregion

#region Godot Overrides
func _ready() -> void:
	settings = load("res://cp_settings.tres")
	if settings == null: return
	var path = settings.external_folder if !OS.has_feature("editor") else settings.cp_folder
	_scan_packs(path)

#endregion

#region Private Support Functions
func _create_pack_cache(pack_path : String) -> void:
	var pack : CachePack = CachePack.new()
	pack.config = load(pack_path.path_join("pack_config.tres")) as CPConfig
	pack.instance = load(pack_path.path_join("pack_script.gd")).new()
	pack.instance.pack_config = pack.config
	pack.res_path = pack_path
	_packs.append(pack)

func _scan_from_editor(path : String) -> void:
	var packs = DirAccess.get_directories_at(path)
	for pack in packs:
		var pack_path = path.path_join(pack)
		var config = pack_path.path_join("pack_config.tres")
		var script = pack_path.path_join("pack_script.gd")
		if not FileAccess.file_exists(config) and not FileAccess.file_exists(script):
			continue  # Not a Valid Pack
		_create_pack_cache(pack_path)

func _scan_from_project(path : String, scan_new : bool = false) -> int:
	var found : int = 0
	var packs = DirAccess.get_files_at(path)
	for pack in packs:
		var valid_pack : String
		if settings.format == CPSettings.PackFormat.PCK and pack.ends_with(".pck"):
			valid_pack = path.path_join(pack)
		elif settings.format == CPSettings.PackFormat.ZIP and pack.ends_with(".zip"):
			valid_pack = path.path_join(pack)
		else:
			valid_pack = ""
		
		if valid_pack == "": continue # Not a valid pack

		if scan_new and valid_pack in _found:
			continue
		
		found += 1
		var folders := DirAccess.get_directories_at(settings.cp_folder)
		ProjectSettings.load_resource_pack(valid_pack, false)
		var pack_folders = Array(DirAccess.get_directories_at(settings.cp_folder)).filter(func(x): return not x in folders)
		if pack_folders.is_empty(): continue # Not a valid pack
		var pack_path := settings.cp_folder.path_join(pack_folders[0])
		_found.append(valid_pack)
		_create_pack_cache(pack_path)
	return found

func _scan_packs(path : String) -> void:
	if OS.has_feature("editor"):
		_scan_from_editor()
	else:
		if !DirAccess.dir_exists_absolute(settings.external_folder):
			DirAccess.make_dir_recursive_absolute(settings.external_folder)
			return
		
		_scan_from_project(path)

func _get_pack(pack : String) -> CachePack:
	var packs = _packs.filter(func(x : CachePack): return x.name == pack)
	return packs[0] if packs.size() == 1 else null
#endregion

## Goes through all packs that were scanned, and executes each pack's configure function.
## You can provide any form of data to the function that will allow the Content Packs to configure
## their setup, executing the pack's _configure() method.
func configure_packs(data : Variant) -> void:
	for pack in _packs:
		pack.instance.configure(data)

## Specifically configures a pack by given name, with the data that was provided, executing the _configure() method.
func configure_pack(pack : String, data : Variant) -> void:
	var cpack = _get_pack(pack)
	if cpack:
		cpack.instance.configure(data)

## Iterates through all packs, and executes their _setup() method.
func setup_packs() -> void:
	for pack in _packs:
		pack.instance.setup()

## Specifically setup's a pack by name, executing it's _setup() method.
func setup_pack(pack : String) -> void:
	var cpack = _get_pack(pack)
	if cpack:
		cpack.instance.setup()

## Execute's enabling of all packs that were scanned, executing _enable_pack() method.
func enable_all_packs() -> void:
	for pack in _packs:
		pack.instance.enable_pack()

## Enables a specific pack by name, executes pack's _enable_pack() method.
func enable_pack(pack : String) -> void:
	var cpack = _get_pack(pack)
	if cpack:
		cpack.instance.enable_pack()

## Execute's disabling of all packs that were scanned, executing _disable_pack() method.
func disable_all_packs() -> void:
	for pack in _packs:
		pack.instance.disable_pack()

## Disables a specific pack by name, executes pack's _disable_pack() method.
func disable_pack(pack : String) -> void:
	var cpack = _get_pack(pack)
	if cpack:
		cpack.instance.disable_pack()

## Checks to see if a Content Pack has been enabled.  Executes pack's _is_enabled() method.
func is_pack_enabled(pack : String) -> bool:
	var cpack = _get_pack(pack)
	if cpack:
		return cpack.instance.is_enabled()
	else:
		return false

## Returns a list of packs found at start of project, as an Array of strings.
func get_pack_names() -> Array[String]:
	var pack_names : Array[String]
	pack_names.assign(_packs.map(func(pack : CachePack): return pack.name))
	return pack_names

## Returns a pack's metadata configuration, by given pack name.
func get_pack_config(pack : String) -> CPConfig:
	var cpack = _get_pack(pack)
	if cpack:
		return cpack.config
	else:
		return null

## Returns internal path to the pack, as seen inside the Godot File structure.  (EG: res://dlc/my_mod_pack/)
func get_pack_path(pack : String) -> String:
	var cpack = _get_pack(pack)
	if cpack:
		return cpack.res_path
	else:
		return ""

## Scans for new packs that wasn't found while doing normal scanning, ensuring that the PackManager is up
## to date.  Returns the number of found packs.
func scan_for_new() -> int:
	var found : int = 0

	if not OS.has_feature("editor"):
		found = _scan_from_project(settings.external_folder, true)
	return found

class CachePack:
	var name : String :
		get(): return config.name
	var config : CPConfig
	var instance : PackScript
	var res_path : String
