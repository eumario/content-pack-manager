class_name CPConfig extends Resource

@export var name : String
@export var author : String
@export var version : String
@export var description : String
@export var url : String
@export var icon_path : String
@export var pack_version : String

var SemanticVersion : SemVersion :
	get(): return SemVersion.from_string(version)

func launch_url() -> void:
	if url == "": return
	OS.shell_open(url)
