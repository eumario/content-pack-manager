@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var versions : Array[SemVersion] = [
		SemVersion.from_string("0.0.1"),
		SemVersion.coerce("4.4-beta1"),
		SemVersion.from_string("3.1.1"),
		SemVersion.from_string("4.1.4"),
		SemVersion.from_string("4.3.0-dev1"),
		SemVersion.from_string("4.3.0-alpha4"),
		SemVersion.from_string("4.3.0-beta3"),
		SemVersion.from_string("4.3.0-beta"),
		SemVersion.from_string("0.1.0"),
		SemVersion.from_string("4.3.0-rc1"),
		SemVersion.from_string("4.3.0"),
		SemVersion.from_string("1.0.0"),
		SemVersion.from_string("1.2.0"),
	]
	
	print("Un-ordered Array: ", versions)
	versions.sort_custom(func(a,b): return a.is_newer_than(b))
	print("Sorted Array: ", versions)
