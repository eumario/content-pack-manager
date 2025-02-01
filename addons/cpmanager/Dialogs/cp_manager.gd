@tool
extends Window

#region Private Variables
var _cp_version : String = "0.1.0"
var _cp_sem_version : SemVersion = SemVersion.from_string(_cp_version)
#endregion

#region Properties
var settings : CPSettings :
	set(value):
		settings = value
		if get_node_or_null("%BuildFolder") != null and settings != null:
			%Settings.settings = value
			%"Content Packs".settings = value
			%"Build Output".settings = value
	get(): return settings
#endregion

#region Godot Overrides
func _ready() -> void:
	var loaded_settings = null
	if FileAccess.file_exists("res://cp_settings.tres"):
		loaded_settings = load("res://cp_settings.tres")
	
	if loaded_settings != null:
		if _cp_sem_version.is_newer_than(SemVersion.from_string(loaded_settings.cp_version)):
			_run_upgrades(loaded_settings)
		self.settings = loaded_settings
		%"Content Packs".visible = true
	else:
		%Settings.visible = true
		%Settings.created_settings.connect(_handle_settings_created)

#endregion

#region Private Functions
func _run_upgrades(the_settings : CPSettings) -> void:
	pass # First Version, no Upgrading needs to occur.
#endregion

#region Signal Handlers
func _handle_settings_created(new_settings : CPSettings) -> void:
	self.settings = new_settings
	%"Content Packs".visible = true
#endregion
