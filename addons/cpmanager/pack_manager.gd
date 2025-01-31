extends Node

static var settings : CPSettings
static var _packs : Array[CachePack] = []

func _ready() -> void:
	settings = load("res://cp_settings.tres")
	if settings == null: return
	var path = settings.external_folder if !OS.has_feature("editor") else settings.cp_folder
	_scan_packs(path)

func _create_pack_cache(pack_path : String) -> void:
	var pack : CachePack = CachePack.new()
	pack.config = load(pack_path.path_join("pack_config.tres")) as CPConfig
	pack.instance = load(pack_path.path_join("pack_script.gd")).new()
	pack.instance.pack_config = pack.config
	pack.res_path = pack_path
	_packs.append(pack)

func _scan_packs(path : String) -> void:
	if OS.has_feature("editor"):
		var packs = DirAccess.get_directories_at(path)
		for pack in packs:
			var pack_path = path.path_join(pack)
			var config = pack_path.path_join("pack_config.tres")
			var script = pack_path.path_join("pack_script.gd")
			if not FileAccess.file_exists(config) and not FileAccess.file_exists(script):
				continue  # Not a Valid Pack
			_create_pack_cache(pack_path)
	else:
		if !DirAccess.dir_exists_absolute(settings.external_folder):
			DirAccess.make_dir_recursive_absolute(settings.external_folder)
			return
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
			
			var folders := DirAccess.get_directories_at(settings.cp_folder)
			ProjectSettings.load_resource_pack(valid_pack, false)
			var pack_folders = Array(DirAccess.get_directories_at(settings.cp_folder)).filter(func(x): return not x in folders)
			if pack_folders.is_empty(): continue # Not a valid pack
			var pack_path := settings.cp_folder.path_join(pack_folders[0])
			_create_pack_cache(pack_path)

func _get_pack(pack : String) -> CachePack:
	var packs = _packs.filter(func(x : CachePack): return x.name == pack)
	return packs[0] if packs.size() == 1 else null

func configure_packs(data : Variant) -> void:
	for pack in _packs:
		pack.instance.configure(data)

func configure_pack(pack : String, data : Variant) -> void:
	var cpack = _get_pack(pack)
	if cpack:
		cpack.instance.configure(data)

func setup_packs() -> void:
	for pack in _packs:
		pack.instance.setup()

func setup_pack(pack : String) -> void:
	var cpack = _get_pack(pack)
	if cpack:
		cpack.instance.setup()

func enable_all_packs() -> void:
	for pack in _packs:
		pack.instance.enable_pack()

func enable_pack(pack : String) -> void:
	var cpack = _get_pack(pack)
	if cpack:
		cpack.instance.enable_pack()

func disable_all_packs() -> void:
	for pack in _packs:
		pack.instance.disable_pack()

func disable_pack(pack : String) -> void:
	var cpack = _get_pack(pack)
	if cpack:
		cpack.instance.disable_pack()

func is_pack_enabled(pack : String) -> bool:
	var cpack = _get_pack(pack)
	if cpack:
		return cpack.instance.is_enabled()
	else:
		return false

func get_pack_names() -> Array[String]:
	var pack_names : Array[String]
	pack_names.assign(_packs.map(func(pack : CachePack): return pack.name))
	return pack_names

func get_pack_config(pack : String) -> CPConfig:
	var cpack = _get_pack(pack)
	if cpack:
		return cpack.config
	else:
		return null

func get_pack_path(pack : String) -> String:
	var cpack = _get_pack(pack)
	if cpack:
		return cpack.res_path
	else:
		return ""

class CachePack:
	var name : String :
		get(): return config.name
	var config : CPConfig
	var instance : PackScript
	var res_path : String
