@tool
class_name ExportConfigurator extends RefCounted

var export_path : String = "res://export_presets.cfg"
var cfg : ConfigFile
var preset_dict : Dictionary = {
	name = "", #name="dlc_corgi"
	platform = "Windows Desktop", #platform="Windows Desktop"
	runnable = false,
	advanced_options = false,
	dedicated_server = false,
	custom_features = "",
	export_filter = "resources",
	export_files = PackedStringArray([]),
	include_filter = "",
	exclude_filter = "",
	export_path = "",
	encryption_include_filters = "",
	encryption_exclude_filters = "",
	encrypt_pck = false,
	encrypt_directory = false,
	script_export_mode = 2,
}

var preset_options_dict : Dictionary = {
	"custom_template/debug" = "",
	"custom_template/release" = "",
	"debug/export_console_wrapper" = 1,
	"binary_format/embed_pck" = false,
	"texture_format/s3tc_bptc" = true,
	"texture_format/etc2_astc" = false,
	"binary_format/architecture" = "x86_64",
}

func load_config() -> void:
	if cfg != null:
		cfg.save(export_path)
		cfg.free()
	cfg = ConfigFile.new()
	var err := cfg.load(export_path)
	assert(err == OK, "Failed to load config file: %s" % (err as Error))

func add_pack_preset(pack : CPConfig, files : Array[String]) -> void:
	assert(cfg != null, "Please load configuratin before running.")
	
	var sections = cfg.get_sections()
	var i : int = 0
	for section in sections:
		if section.count(".") > 1: continue
		i += 1
	var section_main = "preset.%s" % i
	var section_options = "preset.%s.options" % i
	var preset = preset_dict.duplicate(true)
	preset.name = "pack_%s" % pack.name.to_snake_case()
	preset.export_files = PackedStringArray(files)
	
	for key in preset.keys():
		cfg.set_value(section_main, key, preset[key])
	
	for key in preset_options_dict.keys():
		cfg.set_value(section_options, key, preset_options_dict[key])
	
	cfg.save(export_path)

func update_pack_preset(pack : CPConfig, files : Array[String]) -> void:
	assert(cfg != null, "Please load configuration before running.")
	
	for section in cfg.get_sections():
		if section.count(".") > 1: continue
		if cfg.get_value(section, "name", "") != "pack_%s" % pack.name.to_snake_case(): continue
		
		cfg.set_value(section, "export_files", PackedStringArray(files))
		cfg.save(export_path)
		break

func has_pack_preset(pack : CPConfig) -> bool:
	assert(cfg != null, "Please load configuration before running.")
	
	for section in cfg.get_sections():
		if section.count(".") > 1: continue
		if cfg.get_value(section, "name", "") != "pack_%s" % pack.name.to_snake_case(): continue
		return true
	return false
