class_name PackScript extends RefCounted

var pack_config : CPConfig

#region Virtual Functions
func _setup() -> void:
	pass

func _configure(data : Variant) -> void:
	pass

func _enable_pack() -> void:
	pass

func _disable_pack() -> void:
	pass

func _is_enabled() -> bool:
	return false

#endregion

func setup() -> void:
	_setup()

func configure(data : Variant) -> void:
	_configure(data)

func enable_pack() -> void:
	_enable_pack()

func disable_pack() -> void:
	_disable_pack()

func is_enabled() -> bool:
	return _is_enabled()
