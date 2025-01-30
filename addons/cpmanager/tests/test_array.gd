@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var arr_1 = [1,2,3,4,5]
	var arr_2 = [1,2,3,4,5,6,7]
	print(arr_2.filter(func(x): return not x in arr_1))
