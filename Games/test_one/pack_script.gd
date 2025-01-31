extends PackScript

var _my_control : PackedScene = preload("res://Games/test_one/Scenes/main_scene.tscn")
var _my_instance : Control
var _root : Container
var _enabled : bool = false

# Is executed when creating the pack script for the first time.
func _setup() -> void:
	_my_instance = _my_control.instantiate()

# Is executed when using PackManager.configure_pack(pack, data)
func _configure(data : Variant) -> void:
	_root = data as Container

# Is executed when using PackManager.enable_pack(pack)
func _enable_pack() -> void:
	_enabled = true
	_root.add_child(_my_instance)

# Is Executed when using PackManager.disable_pack(pack)
func _disable_pack() -> void:
	_enabled = false
	_root.remove_child(_my_instance)

# Is Executed when using PackManager.is_enabled(pack)
func _is_enabled() -> bool:
	return _enabled
